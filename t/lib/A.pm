package A;

use 5.16.1;
use warnings;

use Data::Dumper::Concise;
use Test::More;
use Test::Deep;

use Sub::Exporter::Progressive -setup => {
  exports => [qw(app stdout_is)],
};

sub stdout_is {
   my ( $result, $expected, $reason ) = @_;

   my @out = split /\n/, $result->stdout;
   local $Test::Builder::Level = $Test::Builder::Level + 1;
   is_deeply(\@out, $expected, $reason || ()) or diag(Dumper({
      stdout => \@out,
      stderr => [split /\n/, $result->stderr],
      error  => $result->error,
   }))
}

sub app {
   require DU::App;

   my $app = DU::App->new({ connect_info => { dsn => 'dbi:SQLite::memory:' }});

   my $s = $app->schema;

   A->_deploy_schema($s);
   A->_populate_schema($s);

   $app
}

sub _deploy_schema {
  my ($self, $schema) = @_;

  require Path::Class;

  my $filename = Path::Class::File->new(__FILE__)->dir
    ->file('sqlite.sql')->stringify;
  my $sql = do { local (@ARGV, $/) = $filename ; <> };
  for my $chunk ( grep { / ^ (?! --\s* ) \S /xm } split (/;\s*\n+/, $sql) ) {
     $schema->storage->dbh_do(sub { $_[1]->do($chunk) })
  }
}

sub _populate_schema {
   my ($self, $s) = @_;

   $s->resultset('Unit')->populate([
      [qw(name gills)],
      [ounce      => 1 / 4         ] ,
      [tablespoon => 1 / 4 / 2     ] ,
      [teaspoon   => 1 / 4 / 2 / 3 ] ,
      [dash       => undef         ] ,
   ]);

my $tom_collins = $s->create_drink({
   description => 'Refreshing beverage for a hot day',
   name => 'Tom Collins',
   ingredients => [{
      name => 'Club Soda',
      unit => 'ounce',
      amount => 4,
   }, {
      name => 'Gin',
      unit => 'ounce',
      amount => 2,
   }, {
      name => 'Lemon Juice',
      unit => 'ounce',
      amount => 1,
   }, {
      name => 'Simple Syrup',
      unit => 'teaspoon',
      amount => 1,
   }],
});

my $cuba_libre = $s->create_drink({
   description => 'Delicious drink all people should try',
   name => 'Cuba Libre',
   ingredients => [{
      unit => 'ounce',
      amount => 4,
      name => 'Coca Cola',
   }, {
      unit => 'ounce',
      amount => 2,
      name => 'Light Rum',
   }, {
      unit => 'ounce',
      amount => 1,
      name => 'Lime Juice',
   }],
});

my $fruba_libre = $s->create_drink({
   description => 'A Delicious beverage of my own design',
   variant_of_drink => $cuba_libre,
   name => 'Frewba Libre',
   ingredients => [{
      unit => 'ounce',
      amount => 4,
      name => 'Coca Cola',
   }, {
      unit => 'ounce',
      amount => 2,
      notes  => q(I recommend using either Myers's Original Dark Jamaican Rum,) .
                q( or skip the vanilla extract and use the excellent black ) .
                q(Kraken Rum.),
      name => 'Dark Rum',
   }, {
      unit => 'ounce',
      amount => 1,
      name => 'Lime Juice',
   }, {
      arbitrary_amount => '3 drops',
      name => 'Vanilla Extract',
   }],
});

   my $f = $s->resultset('User')->create({ name => 'frew' });

   $f->add_to_ingredients($_) for $s->resultset('Ingredient')->search(undef, { rows => 3 })->all;
}

1;
