package DU::App::Command::maint::export;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util qw(ingredient_as_data drink_as_data);

sub abstract { '' }

sub usage_desc { '' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $s = $self->app->app->schema;

   require Archive::Tar;
   require JSON;
   require File::Temp;
   use IO::Compress::Xz 'xz';

   my $tar = Archive::Tar->new;

   $tar->add_data('export_version.txt', 1);
   $tar->add_data('drinks.json',
      JSON::encode_json([
         map drink_as_data($_), $s->resultset('Drink')->all
      ])
   );

   $tar->add_data('ingredients.json',
      JSON::encode_json([
         map ingredient_as_data($_), $s->resultset('Ingredient')->all
      ])
   );

   my $name = $args->[0] || 'export';
   my (undef, $tmptar) = File::Temp::tempfile( OPEN => 0 );
   $tar->write($tmptar);

   xz $tmptar, "$name.tar.xz";
   unlink $tmptar;

   say 'done';
}

1;

