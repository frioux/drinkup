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
   my $ingredient_rs = $s->resultset('Ingredient');
   my @drinks = @{JSON::decode_json($tar->get_content('drinks.json'))};
   my @ingredients = @{JSON::decode_json($tar->get_content('ingredients.json'))};

   unlink $tmptar;

   for my $ingredient_data (@ingredients) {
      if ($ingredient_rs->find_by_name($ingredient_data->{name})) {
         die "$ingredient_data->{name} is already in your database"
      } else {
         $ingredient_rs->create($ingredient_data)
      }
   }

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

