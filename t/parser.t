#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Test::More;
use Test::Deep;

use DU::RecipeParser;

my $tom_collins = <<'RECIPE';
Tom Collins

This is a delicious beverage for a hot day.
Refreshing.

Drink it at a wedding.

 * 4 ounces of Club Soda
*2 ounce Gin
* 1 Ounce of Lemon Juice
# fresh is good
*1 tbsp of Simple Syrup

Source: 500 Cocktails, p27
RECIPE

my $expected = {
   description => "This is a delicious beverage for a hot day.\nRefreshing.\n\nDrink it at a wedding.\n",
   ingredients => [{
      amount => 4,
      ingredient => "Club Soda",
      unit => "ounces"
   }, {
      amount => 2,
      ingredient => "Gin",
      unit => "ounce"
   }, {
      amount => 1,
      ingredient => "Lemon Juice",
      note => "fresh is good",
      unit => "Ounce"
   }, {
      amount => 1,
      ingredient => "Simple Syrup",
      unit => "tbsp"
   }],
   name => "Tom Collins",
   source => "500 Cocktails, p27"
};

cmp_deeply(decode_recipe($tom_collins), $expected, 'Tom Collins');

is(encode_recipe($expected), <<'RECIPE2', 'encoded correctly');
Tom Collins

This is a delicious beverage for a hot day.
Refreshing.

Drink it at a wedding.

 * 4 ounces of Club Soda
 * 2 ounce of Gin
 * 1 Ounce of Lemon Juice
 # fresh is good
 * 1 tbsp of Simple Syrup

Source: 500 Cocktails, p27
RECIPE2
done_testing;
