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

# one of my ingredients is used
sub some {
   my ($self, $user) = @_;

   my $ids = $self->search({
      'ingredient.id' => {
         -in => $user->inventory_items->get_column('ingredient_id')->as_query
      },
   }, {
      join => { links_to_drink_ingredients => 'ingredient' },
      group_by => 'me.id',
   })->get_column('id')->as_query;

   $self->search({ id => { -in => $ids } })
}

# none of my ingredients are used
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

sub every {
   my ($self, $user) = @_;

   my $ii = $self->result_source->schema->resultset('InventoryItem')
      ->search({
         'me.user_id' => $user->id
      }, {
         join => { ingredient => 'links_to_drink_ingredients' },
         columns => {
            drink_id => 'links_to_drink_ingredients.drink_id',
            ingredient_count => { count => '*', -as => 'ingredient_count' },
         },
         group_by => 'links_to_drink_ingredients.drink_id',
      })->as_query;


   my $ri = $self->result_source->schema->resultset('Drink_Ingredient')
      ->search(undef, {
         columns => {
            drink_id => 'me.drink_id',
            ingredient_count => { count => '*', -as => 'ingredient_count' },
         },
         group_by => 'me.drink_id',
      })->as_query;

   my ($ii_sql, @ii_bind) = @{$$ii};
   my ($ri_sql, @ri_bind) = @{$$ri};

   my $creation = \[
   <<"SQL",
      SELECT ri.drink_id FROM (
         $ri_sql ri,
         $ii_sql ii
      )
      WHERE ri.drink_id = ii.drink_id AND
            ri.ingredient_count = ii.ingredient_count
SQL
   @ri_bind, @ii_bind ];

   $self->search({ 'me.id' => { -in => $creation } });
}

1;
