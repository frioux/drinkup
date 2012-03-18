package DU::App::Command::ingredient::Command::rm;

use 5.14.1;
use warnings;

use DU::App::Command::ingredient -command;
use DU::Util;

sub abstract { 'delete ingredient' }

sub usage_desc { 'du ingredient rm $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   DU::Util::single_item(sub {
      $_[0]->delete;

      say 'ingredient (' . $_[0]->name . ') deleted';
   }, 'ingredient', $args->[0], $self->app->app->schema->resultset('Ingredient'));
}

1;

