package DU::App::Command::ingredient::ls;

use 5.16.1;
use Moo;

extends 'DU::App::Command';

sub abstract { 'list ingredients' }

sub usage_desc { 'du ingredient list' }

sub execute {
   my ($self, $opt, $args) = @_;

   say '## Ingredients';
   say ' * ' . $_->name for $self->rs('Ingredient')->all
}

1;

