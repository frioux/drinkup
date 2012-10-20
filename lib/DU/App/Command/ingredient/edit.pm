package DU::App::Command::ingredient::edit;

use 5.16.0;
use Moo;

extends 'DU::App::Command';
use DU::Util qw(single_item edit_data ingredient_as_data);

sub abstract { 'edit ingredient' }

sub usage_desc { 'du ingredient edit $ingredient' }

sub execute {
   my ($self, $opt, $args) = @_;

   single_item(sub {
      my $edit = edit_data(ingredient_as_data($_[0]));
      if (my $p_name = delete $edit->{isa}) {
         my $p = $self->rs('Ingredient')->find_or_create({
            name => $p_name
         });
         $edit->{kind_of_id} = $p->id;
      }
      $_[0]->update($edit);

      say 'ingredient (' . $_[0]->name . ') updated';
   }, 'ingredient', $args->[0], $self->rs('Ingredient'));
}

1;

