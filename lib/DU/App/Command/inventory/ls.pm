package DU::App::Command::inventory::ls;

use 5.14.1;
use warnings;

use DU::App -command;

sub abstract { 'remove ingredient from inventory' }

sub usage_desc { 'du inventory rm $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $rs = $self->app->app->schema
     ->resultset('User')
     ->search({ 'me.name' => 'frew' })
     ->related_resultset('inventory_items')
     ->related_resultset('ingredient');

   say '## Inventory';
   say ' * ' . $_->name for $rs->all;
}

1;

