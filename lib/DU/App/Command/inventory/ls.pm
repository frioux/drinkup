package DU::App::Command::inventory::ls;

use 5.16.0;
use Moo;

extends 'DU::App::Command';

sub abstract { 'list inventory' }

sub usage_desc { 'du ls' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $rs = $self
     ->rs('User')
     ->search({ 'me.name' => 'frew' })
     ->related_resultset('inventory_items')
     ->related_resultset('ingredient');

   say '## Inventory';
   say ' * ' . $_->name for $rs->all;
}

1;

