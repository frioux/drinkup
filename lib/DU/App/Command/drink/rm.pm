package DU::App::Command::drink::rm;

use 5.16.1;
use Moo;

extends 'DU::App::Command';
use DU::Util;

sub abstract { 'delete drink' }

sub usage_desc { 'du drink rm $drink' }

sub execute {
   my ($self, $opt, $args) = @_;

   DU::Util::single_item(sub {
      $_[0]->delete;

      say 'drink (' . $_[0]->name . ') deleted';
   }, 'drink', $args->[0], $self->rs('Drink'));
}

1;


