package DU::App::Command::maint::export;

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
   use IO::Compress::Xz 'xz';

   my $tar = Archive::Tar->new;

   $tar->add_data('export_version.txt', 1);
   $tar->add_data('drinks.json',
      JSON::encode_json([
         map drink_as_data($_), $s->resultset('Drink')->all
      ])
   );

   my $name = $args->[0] || 'export';
   $tar->write(".$name.tar");

   xz ".$name.tar", "$name.tar.xz";
   unlink ".$name.tar";

   say 'done';
}

1;

