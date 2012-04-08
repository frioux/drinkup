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
      my $edit = DU::Util::edit_data({
         name => $_[0]->name,
         description => $_[0]->description,
         ($_[0]->kind_of_id ? ( isa => $_[0]->kind_of->name ) : ()),
      });
      if (my $p_name = delete $edit->{isa}) {
         my $p = $self->app->app->schema->resultset('Ingredient')->find_or_create({
            name => $p_name
         });
         $edit->{kind_of_id} = $p->id;
      }
      $_[0]->update($edit);

      say 'ingredient (' . $_[0]->name . ') updated';
   }, 'ingredient', $args->[0], $self->app->app->schema->resultset('Ingredient'));
}

1;

