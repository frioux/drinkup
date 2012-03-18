package DU::App::Command::drink::list;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util 'drink_as_markdown';

sub abstract { 'list drinks' }

sub usage_desc { 'du drink list' }

sub execute {
   my ($self, $opt, $args) = @_;

   print drink_as_markdown($_)
     for $self->app->app->schema->resultset('Drink')->all
}

1;
