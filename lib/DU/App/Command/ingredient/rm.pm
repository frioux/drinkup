package DU::App::Command::ingredient::rm;

use 5.16.0;
use Moo;

extends 'DU::App::Command';
use DU::Util;

sub abstract { 'delete ingredient' }

sub usage_desc { 'du ingredient rm $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   DU::Util::single_item(sub {
      $_[0]->delete;

      say 'ingredient (' . $_[0]->name . ') deleted';
   }, 'ingredient', $args->[0], $self->rs('Ingredient'));
}

1;

