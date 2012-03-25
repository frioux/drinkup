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

$s->resultset('Unit')->populate([
   [qw(name gills)],
   [ounce      => 1 / 4         ] ,
   [tablespoon => 1 / 4 / 2     ] ,
   [teaspoon   => 1 / 4 / 2 / 3 ] ,
   [dash       => undef         ] ,
]);

my @correct = ({
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
});

my $tom_collins = $s->create_drink({
   description => 'Refreshing beverage for a hot day',
   name => 'Tom Collins',
   ingredients => \@correct,
});

is $tom_collins->name, 'Tom Collins', 'Name of drink set correctly';

my $links =$tom_collins->links_to_drink_ingredients->search(undef, {
   order_by => 'ingredient.name',
   prefetch => 'ingredient',
});

my $i = 0;
for ($links->all) {
   is $_->ingredient->name, $correct[$i]->{name}, "${i}th name correct";
   is $_->amount, $correct[$i]->{amount}, "${i}th amount correct";
   is $_->unit->name, $correct[$i]->{unit}, "${i}th unit correct";

   $i++;
}
is $links->slice(0)->single->ingredient->name, 'Club Soda';

done_testing;
