package DU::App::Command::ingredient::edit;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util;

sub abstract { 'edit ingredient' }

sub usage_desc { 'du ingredient edit $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   DU::Util::single_item(sub {
      $_[0]->update(
         DU::Util::edit_data({
            name => $_[0]->name,
            description => $_[0]->description,
         })
      );

      say 'ingredient (' . $_[0]->name . ') updated';
   }, 'ingredient', $args->[0], $self->app->app->schema->resultset('Ingredient'));
}

1;
