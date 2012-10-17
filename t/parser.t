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
Variant_of_Drink: foo
RECIPE

my $expected = {
   description => "This is a delicious beverage for a hot day.\nRefreshing.\n\nDrink it at a wedding.",
   ingredients => [{
      amount => 4,
      name => "Club Soda",
      unit => "ounce"
   }, {
      amount => 2,
      name => "Gin",
      unit => "ounce"
   }, {
      amount => 1,
      name => "Lemon Juice",
      note => "fresh is good",
      unit => "ounce"
   }, {
      amount => 1,
      name => "Simple Syrup",
      unit => "tablespoon"
   }],
   name => "Tom Collins",
   source => "500 Cocktails, p27",
   variant_of_drink => "foo",
};

cmp_deeply(decode_recipe($tom_collins), $expected, 'Tom Collins');

is(encode_recipe($expected), <<'RECIPE2', 'encoded correctly');
Tom Collins

This is a delicious beverage for a hot day.
Refreshing.

Drink it at a wedding.

 * 4 ounces of Club Soda
 * 2 ounces of Gin
 * 1 ounce of Lemon Juice
 # fresh is good
 * 1 tablespoon of Simple Syrup

Source: 500 Cocktails, p27
Variant_of_Drink: foo
RECIPE2
done_testing;
