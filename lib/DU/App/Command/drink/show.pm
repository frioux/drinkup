package DU::App::Command::drink::show;

use 5.16.1;
use Moo;

extends 'DU::App::Command';
use DU::Util qw(single_item drink_as_markdown);

sub abstract { 'show drink' }

sub usage_desc { 'dup drink show' }

sub execute {
   my ($self, $opt, $args) = @_;

   single_item(sub {
      print drink_as_markdown($_[0])
   }, 'drink', $args->[0], $self->rs('Drink'));
}

1;

