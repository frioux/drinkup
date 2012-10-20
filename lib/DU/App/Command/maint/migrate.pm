package DU::App::Command::maint::migrate;

use 5.16.0;
use Moo;

extends 'DU::App::Command';
use DU::Util 'single_item';

sub abstract { '' }

sub usage_desc { '' }

sub execute {
   my ($self, $opt, $args) = @_;

   require DU::DeploymentHandler;

   my @args = ( schema => $self->schema );
   my $dbicdh = DU::DeploymentHandler->new(@args);

   if ($dbicdh->version_storage_is_installed) {
      $dbicdh->upgrade
   } else {
      $self->schema->txn_do(sub {
         $dbicdh->install({ version => 1 });
      });
      $dbicdh->upgrade
   }

   say 'done';
}

1;

