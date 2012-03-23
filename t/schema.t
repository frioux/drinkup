#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;

use_ok 'DU::Schema';

my $s = DU::Schema->connect({
   dsn => 'dbi:SQLite::memory:',
   quote_names => 1,
});

$s->deploy;

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

done_testing;
