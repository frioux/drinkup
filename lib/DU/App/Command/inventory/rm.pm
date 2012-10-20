package DU::App::Command::inventory::rm;

use 5.16.0;
use Moo;

extends 'DU::App::Command';
use DU::Util;

sub abstract { 'remove ingredient from inventory' }

sub usage_desc { 'du inventory rm $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $rs = $self
      ->rs('User')
      ->search({ 'me.name' => 'frew' })
      ->related_resultset('inventory_items');

   DU::Util::single_item(sub {
      $_[0]->delete;

      say 'ingredient (' . $_[0]->ingredient->name . ') removed from inventory';
   }, 'ingredient', $args->[0], $rs);
}

1;


