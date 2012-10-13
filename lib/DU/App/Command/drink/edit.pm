package DU::App::Command::drink::edit;

use 5.16.1;
use Moo;

extends 'DU::App::Command';
use DU::Util qw(drink_as_markdown drink_as_data edit_data);
use DU::RecipeParser;

sub abstract { 'edit drink' }

sub usage_desc { 'du drink edit $drink' }

sub opt_spec {
   [ 'from_yaml|Y',   'use YAML to specify the drink' ],
   #[ 'from-recipe|R',   'use .recipe to specify the drink' ],
}

sub execute {
   my ($self, $opt, $args) = @_;

   DU::Util::single_item(sub {
      my $data = drink_as_data($_[0]);

      $_[0]->update(
         $opt->from_yaml
            ? edit_data($data)
            : edit_data($data, {
               out => sub { decode_recipe($_[0]) },
               in  => sub { encode_recipe($_[0]) },
            })
      );

      print drink_as_markdown($_[0]);
      say 'drink (' . $_[0]->name . ') updated';
   }, 'drink', $args->[0], $self->rs('Drink'));
}

1;

