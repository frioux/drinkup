package DU::App::Command::drink::show;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util qw(single_item drink_as_markdown);

sub abstract { 'show drink' }

sub usage_desc { 'dup drink show' }

sub execute {
   my ($self, $opt, $args) = @_;

   single_item(sub {
      print drink_as_markdown($_[0])
   }, 'drink', $args->[0], $self->app->app->schema->resultset('Drink'));
}

1;

