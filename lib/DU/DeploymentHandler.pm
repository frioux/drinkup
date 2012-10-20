package DU::DeploymentHandler;

use 5.16.0;
use Moo;
use DateTime;
use DU::Util;

extends 'DBIx::Class::DeploymentHandler';

sub BUILDARGS {
   my $self = shift;

   my $args = $self->next::method(@_);

   $args->{script_directory} = 'usr/migrations';

   $args
}

sub upgrade {
  my $self = shift;
  while ( my $version_list = $self->next_version_set ) {
     $self->upgrade_single_step({ version_set => $version_list })
  }
}

sub upgrade_single_step {
   my $self = shift;

   my ( $from, $to ) = @{$_[0]->{version_set}};
   $self->schema->storage->dbh_do(sub {
      $_[1]->sqlite_backup_to_file(
         DateTime->now->strftime("%Y-%m-%d-%H-%M-%S") . "-db-$from.sqlite.bak"
      )
   });

   my $g = $self->schema->txn_scope_guard;

   my $ret = $self->next::method(@_);
   my ($ddl, $upgrade_sql) = @{$ret||[]};

   $self->add_database_version({
     version     => $to,
     ddl         => $ddl,
     upgrade_sql => $upgrade_sql,
   });

   $g->commit;
   $ret
}

1;
