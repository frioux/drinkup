package DU::App::Command::ingredient::list;

use 5.14.1;
use warnings;

use DU::App -command;

sub abstract { 'list ingredients' }

sub usage_desc { 'du ingredient list' }

sub execute {
   my ($self, $opt, $args) = @_;

   say '## Ingredients';
   say ' * ' . $_->name for $self->app->app->schema->resultset('Ingredient')->all
}

1;

