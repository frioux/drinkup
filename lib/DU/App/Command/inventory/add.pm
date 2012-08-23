package DU::App::Command::inventory::add;

use 5.16.1;
use Moo;

extends 'DU::App::Command';
use DU::Util 'single_item';

sub abstract { 'add ingredient to inventory' }

sub usage_desc { 'du inventory add $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $ii = $self
     ->rs('User')
     ->search({ 'me.name' => 'frew' })
     ->related_resultset('inventory_items');

    my $q = $ii
     ->related_resultset('ingredient')
     ->get_column('id')
     ->as_query;

   my $rs = $self
      ->rs('Ingredient')->search({
         id => { -not_in => $q }
      });

   single_item(sub {
      $ii->create({ user => { name => 'frew' }, ingredient_id => $_[0]->id });

      say 'ingredient (' . $_[0]->name . ') added to inventory';
   }, 'ingredient', $args->[0], $rs);
}

1;

