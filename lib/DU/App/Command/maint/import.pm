package DU::App::Command::maint::import;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util 'drink_as_data';

sub abstract { '' }

sub usage_desc { '' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $s = $self->app->app->schema;

   require Archive::Tar;
   require JSON;
   require File::Temp;
   use IO::Uncompress::UnXz 'unxz';

   my $name = $args->[0] || 'export';
   my (undef, $tmptar) = File::Temp::tempfile( OPEN => 0 );
   unxz "$name.tar.xz", $tmptar;

   my $tar = Archive::Tar->new;

   $tar->read($tmptar, { extract => 1 });

   my $version = $tar->get_content('export_version.txt');

   my $drink_rs = $s->resultset('Drink');
   my @drinks = @{JSON::decode_json($tar->get_content('drinks.json'))};
   unlink $tmptar;

   for my $drink_data (@drinks) {
      if ($drink_rs->find_by_name($drink_data->{name})) {
         die "$drink_data->{name} is already in your database"
      } else {
         $s->create_drink($drink_data)
      }
   }

   say 'done';
}

1;

