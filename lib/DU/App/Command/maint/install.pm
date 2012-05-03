package DU::App::Command::maint::install;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util 'single_item';

sub abstract { '' }

sub usage_desc { '' }

sub opt_spec {
   [ 'seeding!',  'use this to disable seeding', { default => 1 } ],
}

sub execute {
   my ($self, $opt, $args) = @_;

   use lib 't/lib';
   require A;
   my $s = $self->app->app->schema;

   A->_deploy_schema($s);
   A->_populate_schema($s) if $opt->seeding;

   say 'done';
}

1;

