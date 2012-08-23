package DU::App::Command;

use 5.16.1;
use warnings;

use parent 'App::Cmd::Command';

sub schema { $_[0]->app->app->schema }
sub rs { $_[0]->schema->resultset($_[1]) }

1;

