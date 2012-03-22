package DU::App::Command::inventory::add;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util 'single_item';

sub abstract { 'remove ingredient from inventory' }

sub usage_desc { 'du inventory rm $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $ii = $self->app->app->schema
     ->resultset('User')
     ->search({ 'me.name' => 'frew' })
     ->related_resultset('inventory_items');

    my $q = $ii
     ->related_resultset('ingredient')
     ->get_column('id')
     ->as_query;

   my $rs = $self->app->app->schema
      ->resultset('Ingredient')->search({
         id => { -not_in => $q }
      });

   single_item(sub {
      $ii->create({ user => { name => 'frew' }, ingredient_id => $_[0]->id });

      say 'ingredient (' . $_[0]->name . ') added to inventory';
   }, 'ingredient', $args->[0], $rs);
}

1;

