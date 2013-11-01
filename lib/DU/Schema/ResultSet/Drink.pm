package DU::Schema::ResultSet::Drink;

use 5.16.0;
use Moo;

extends 'DU::Schema::ResultSet';

use Carp 'croak';
use Scalar::Util 'blessed';

sub FOREIGNBUILDARGS { $_[2] }

sub create {
   my ($self, $args) = @_;

   croak 'ingredients arrayref is required!'
      unless $args->{ingredients} and
         ref $args->{ingredients} eq 'ARRAY';

   my @variant;

   if (my $vn = $args->{variant_of_drink}) {
      my $v;
      if (blessed $vn) {
         $v = $vn;
      } else {
         $v = $self->find_by_name($vn)
            or die "no such drink $vn";
      }
      @variant = ( variant_of_drink_id => $v->id )
   }

   my @links = map {
      my @unit;
      if ($_->{unit}) {
         my $unit_id = $self->result_source->schema->resultset('Unit')
            ->search({ name => $_->{unit} })
            ->get_column('id')
            ->single
            or die "unknown unit $_->{unit} used";
         @unit = ( unit_id => $unit_id )
      }

      +{
         ( $_->{arbitrary_amount}
            ? ( arbitrary_amount => $_->{arbitrary_amount} )
            : ()
         ),
         @unit,

         ( $_->{notes}  ? ( notes  => $_->{notes}  ) : () ),
         ( $_->{amount}  ? ( amount  => $_->{amount}  ) : () ),
         ( $_->{amount}  ? ( amount  => $_->{amount}  ) : () ),
         ingredient => { name => $_->{name} },
      }
   }  @{$args->{ingredients}};
   $self->next::method({
      description => $args->{description},
      source => $args->{source},
      @variant,
      names => [{
         name => $args->{name},
         order => 1,
      }],
      links_to_drink_ingredients => \@links,
   })
}

sub find_by_name {
   $_[0]->search({
      'names.name' => $_[1],
   }, {
      join => 'names',
      rows => 1,
   })->next
}

sub cli_find {
   $_[0]->search({
      'names.name' => $_[0]->_glob_to_like($_[1]),
   }, {
      join => 'names',
   })
}

sub some_by_user_inventory {
   $_[0]->some_by_ingredient_id(
      $_[1]->inventory_items->get_column('ingredient_id')->as_query
   )
}

sub some_by_ingredient_id {
   my ($self, $ingredient_ids) = @_;

   my $ids = $self->search({
      'kind_of.id' => {
         -in => $ingredient_ids,
      },
   }, {
      join => { links_to_drink_ingredients => { ingredient => 'kind_of' } },
      group_by => 'me.id',
   })->get_column('id')->as_query;

   $self->search({ id => { -in => $ids } })
}

sub none_by_user_inventory {
   my $i = $_[0]->result_source->schema->resultset('InventoryItem')
      ->search({
         'me.user_id' => $_[1]->id
      })->related_resultset('ingredient');

   $_[0]->none($i)
}

sub none_by_ingredient_id {
   my $i = $_[0]->result_source->schema->resultset('Ingredient')
      ->search({
         'me.id' => $_[1]
      });

   $_[0]->none($i)
}

sub none {
   my ($self, $ingredient_rs) = @_;

   my $q = $ingredient_rs
      ->related_resultset('kind_of')
      ->related_resultset('links_to_drink_ingredients')
      ->related_resultset('drink')
      ->search({
         'drink.id' => { -ident => 'none_search.id' },
      })
      ->as_query;

   my $ids = $self->search({
      -not_exists => $q,
   }, {
      alias    => 'none_search',
      group_by => 'none_search.id',
   })->get_column('id')->as_query;

   $self->search({ id => { -in => $ids } })
}

sub ineq_by_user {
   my ($self, $user, $min, $max) = @_;

   my $ingredient_rs = $user->ingredients;

   $self->ineq($ingredient_rs, $min, $max);
}

sub ineq_by_ingredient_id {
   my ($self, $user, $min, $max) = @_;

   my $ingredient_rs = $_[0]->result_source->schema->resultset('Ingredient')
      ->search({
         'me.id' => $_[1]
      });

   $self->ineq($ingredient_rs, $min, $max);
}

sub ineq {
   my ($self, $ingredient_rs, $min, $max) = @_;

   my $ingredients_on_hand = $ingredient_rs
      ->search(undef, {
         join => { kind_of => 'links_to_drink_ingredients' },
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

sub nearly_by_user { $_[0]->ineq_by_user($_[1], $_[2], $_[2]); }

sub nearly_by_ingredient_id { $_[0]->ineq_by_ingredient_id($_[1], $_[2], $_[2]); }

sub nearly { $_[0]->ineq($_[1], $_[2], $_[2]); }

sub every_by_user { $_[0]->nearly_by_user($_[1], 0) }

sub every_by_ingredient_id { $_[0]->nearly_by_ingredient_id($_[1], 0) }

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
