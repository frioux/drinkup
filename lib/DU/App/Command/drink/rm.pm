package DU::App::Command::drink::rm;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util;

sub abstract { 'delete drink' }

sub usage_desc { 'du drink rm $drink' }

sub execute {
   my ($self, $opt, $args) = @_;

   DU::Util::single_item(sub {
      $_[0]->delete;

      say 'drink (' . $_[0]->name . ') deleted';
   }, 'drink', $args->[0], $self->app->app->schema->resultset('Drink'));
}

1;


