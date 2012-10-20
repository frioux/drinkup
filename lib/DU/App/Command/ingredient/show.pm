package DU::App::Command::ingredient::show;

use 5.16.0;
use Moo;

extends 'DU::App::Command';
use DU::Util qw(single_item ingredient_as_markdown);

sub abstract { 'show ingredient' }

sub usage_desc { 'dup ingredient show' }

sub execute {
   my ($self, $opt, $args) = @_;

   single_item(sub {
      print ingredient_as_markdown($_[0])
   }, 'ingredient', $args->[0], $self->rs('Ingredient'));
}

1;

