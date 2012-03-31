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

1;
