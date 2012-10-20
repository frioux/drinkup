package DU::App;

use 5.16.0;
use Moo;

extends 'App::Cmd';

has schema => (
   is => 'ro',
   builder => '_build_schema',
   lazy => 1,
);

has connect_info => (
   is => 'ro',
   required => 1,
);

sub _build_schema {
   require DU::Schema;

   my $s = DU::Schema->connect({
      quote_names => 1,
      %{ $_[0]->connect_info },
   });

   $s
}

sub _plugins {
   "DU::App::Command::ingredient",
   "DU::App::Command::drink",
   "DU::App::Command::inventory",
   "DU::App::Command::maint",
}

1;
