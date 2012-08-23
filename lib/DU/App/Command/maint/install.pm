package DU::App::Command::maint::install;

use 5.16.1;
use Moo;

extends 'DU::App::Command';
use DU::Util 'single_item';

sub _build_dh {
   require DBIx::Class::DeploymentHandler;

   DBIx::Class::DeploymentHandler->new(
      schema => $_[0]->schema,
   )
}

sub abstract { '' }

sub usage_desc { '' }

sub opt_spec {
   [ 'seeding!',  'use this to disable seeding', { default => 1 } ],
}

sub execute {
   my ($self, $opt, $args) = @_;

   use lib 't/lib';
   require A;
   my $s = $self->schema;

   A->_deploy_schema($s);
   A->_populate_schema($s) if $opt->seeding;

   say 'done';
}

1;

