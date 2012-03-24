package A;

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
  for my $chunk ( split (/;\s*\n+/, $sql) ) {
    if ( $chunk =~ / ^ (?! --\s* ) \S /xm ) {  # there is some real sql in the chunk - a non-space at the start of the string which is not a comment
      $schema->storage->dbh_do(sub { $_[1]->do($chunk) }) or print "Error on SQL: $chunk\n";
    }
  }
}

sub _populate_schema {
   my ($self, $s) = @_;

my $tom_collins = $s->create_drink({
   description => 'Refreshing beverage for a hot day',
   name => 'Tom Collins',
   ingredients => [{
      name => 'Club Soda',
      volume => 1,
   }, {
      name => 'Gin',
      volume => .5,
   }, {
      name => 'Lemon Juice',
      volume => .25,
   }, {
      name => 'Simple Syrup',
      volume => 1 / 24,
   }],
});

my $cuba_libre = $s->resultset('Drink')->create({
   description => 'Delicious drink all people should try',
   names => [{
      name => 'Cuba Libre',
      order => 1,
   }],
   links_to_drink_ingredients => [{
      volume => 1,
      ingredient => { name => 'Coca Cola' },
   }, {
      volume => 0.5,
      ingredient => { name => 'Light Rum' },
   }, {
      volume => 0.25,
      ingredient => { name => 'Lime Juice' },
   }],
});

my $fruba_libre = $s->resultset('Drink')->create({
   description => 'A Delicious beverage of my own design',
   variant_of_drink_id => $cuba_libre->id,
   names => [{
      name => 'Frewba Libre',
      order => 1,
   }],
   links_to_drink_ingredients => [{
      volume => 1,
      ingredient => { name => 'Coca Cola' },
   }, {
      volume => 0.5,
      notes  => q(I recommend using either Myers's Original Dark Jamaican Rum,) .
                q( or skip the vanilla extract and use the excellent black ) .
                q(Kraken Rum.),
      ingredient => { name => 'Dark Rum' },
   }, {
      volume => 0.25,
      ingredient => { name => 'Lime Juice' },
   }, {
      arbitrary_volume => '3 drops',
      ingredient => { name => 'Vanilla Extract' },
   }],
});

   my $f = $s->resultset('User')->create({ name => 'frew' });

   $f->add_to_ingredients($_) for $s->resultset('Ingredient')->search(undef, { rows => 3 })->all;
}

1;
