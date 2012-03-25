#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;

use lib 't/lib';

use A;
use_ok 'DU::Schema';

my $s = DU::Schema->connect({
   dsn => 'dbi:SQLite::memory:',
   quote_names => 1,
});

A->_deploy_schema($s);

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

is $tom_collins->name, 'Tom Collins', 'Name of drink set correctly';

my $links =$tom_collins->links_to_drink_ingredients->search(undef, {
   order_by => 'ingredient.name',
   prefetch => 'ingredient',
});

my @correct = ({
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
});

my $i = 0;
for ($links->all) {
   is $_->ingredient->name, $correct[$i]->{name}, "${i}th name correct";
   is $_->volume, $correct[$i]->{volume}, "${i}th volume correct";

   $i++;
}
is $links->slice(0)->single->ingredient->name, 'Club Soda';

done_testing;
