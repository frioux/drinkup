package DU::Schema::ResultSet::Drink;

use 5.14.1;
use warnings;

use parent 'DU::Schema::ResultSet';

sub cli_find {
   $_[0]->search({
      'names.name' => $_[0]->_glob_to_like($_[1]),
   }, {
      join => 'names',
   })
}

sub some {
   my ($self, $user) = @_;

   my $ids = $self->search({
      'kind_of.id' => {
         -in => $user->inventory_items->get_column('ingredient_id')->as_query
      },
   }, {
      join => { links_to_drink_ingredients => { ingredient => 'kind_of' } },
      group_by => 'me.id',
   })->get_column('id')->as_query;

   $self->search({ id => { -in => $ids } })
}

sub none {
   my ($self, $user) = @_;

   #my $ii = $user->inventory_items;

   my $ii = $self->result_source->schema->resultset('InventoryItem')
      ->search({
         'ii.user_id' => $user->id
      }, {
         alias => 'ii',
      });

   my $q = $ii
      ->related_resultset('ingredient')
      ->related_resultset('kind_of')
      ->related_resultset('links_to_drink_ingredients')
      ->related_resultset('drink')
      ->search({
         'drink.id' => { -ident => 'me.id' },
      }, {
         #alias => 'ud',
      })
      ->as_query;

   my $ids = $self->search({
      -not_exists => $q,
   }, {
      group_by => 'me.id',
   })->get_column('id')->as_query;

   $self->search({ id => { -in => $ids } })
}

sub ineq {
   my ($self, $user, $min, $max) = @_;

   my $ingredients_on_hand = $self->result_source->schema->resultset('InventoryItem')
      ->search({
         'me.user_id' => $user->id
      }, {
         join => { ingredient => { kind_of => 'links_to_drink_ingredients' } },
         columns => {
            drink_id => 'links_to_drink_ingredients.drink_id',
            ingredient_count => { count => '*', -as => 'ingredient_count' },
         },
         group_by => 'links_to_drink_ingredients.drink_id',
      })->as_query;


   my $required_ingredients = $self->result_source->schema->resultset('Drink_Ingredient')
      ->search(undef, {
         columns => {
            drink_id => 'me.drink_id',
            ingredient_count => { count => '*', -as => 'ingredient_count' },
         },
         group_by => 'me.drink_id',
      })->as_query;

   my ($ioh_sql, @ioh_bind) = @{$$ingredients_on_hand};
   my ($ri_sql, @ri_bind) = @{$$required_ingredients};

   my $creation = \[
   <<"SQL",
      SELECT di.drink_id FROM (
         $ri_sql di,
         $ioh_sql ii
      )
      WHERE di.drink_id = ii.drink_id AND
            di.ingredient_count >= ii.ingredient_count + ? AND
            di.ingredient_count <= ii.ingredient_count + ?
SQL
   @ri_bind, @ioh_bind, [{ sqlt_datatype => 'int' } => $min], [{ sqlt_datatype => 'int' } => $max] ];

   $self->search({ 'me.id' => { -in => $creation } });
}

sub nearly { $_[0]->ineq($_[1], $_[2], $_[2]); }

sub every { $_[0]->nearly($_[1], 0) }

1;

__END__

=pod

=head1 METHODS

=head2 cli_find

 $rs->cli_find('lem*');

Drinks with a name that L<matches|DU::Schema::ResultSet/_glob_to_like>
the passed string.

=head2 some

 $rs->some($user)

Drinks that the passed user has at least one ingredient for

=head2 none

 $rs->none($user)

Drinks that the passed user has no ingredients for

=head2 ineq

 $rs->ineq($user, 1, 3)

Drinks that the passed user could make if he bought $x to $y ingredients,
inclusive.

=head2 nearly

 $rs->nearly($user, 2)

Drinks that the passed user could make if he bought exactly $x ingredients

=head2 every

Drinks that the passed user can make given his current inventory
