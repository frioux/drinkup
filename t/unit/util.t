#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Test::More;
use Test::Deep;
use Test::Exit;

use DU::Util ':all';

subtest volume_with_unit => sub {
   is(
      volume_with_unit(
         Ingredient->new( arbitrary_amount => 'Package' )
      ),
      'Package',
      'arbitrary_amount works',
   );

   is(
      volume_with_unit(
         Ingredient->new(
            unit_name => 'ounce',
            amount    => .5,
         )
      ),
      '0.5 ounces',
      'unit_names + amount',
   );

   is(
      volume_with_unit(
         Ingredient->new(
            unit_name => 'ounce',
            amount    => 1,
         )
      ),
      '1 ounce',
      'unit_name + amount',
   );

   is(
      volume_with_unit(
         Ingredient->new( amount    => 1 )
      ),
      '???',
      'no unit!',
   );
};

my $gin_1 = Ingredient->new(
   ingredient_name => 'Gin',
   unit_name => 'ounce',
   amount    => 2,
);

my $g_t = Drink->new(
   name => 'Gin and Tonic',
   links_to_drink_ingredients => RSFaker->new(
      $gin_1,
      Ingredient->new(
         ingredient_name => 'Tonic',
         unit_name => 'ounce',
         amount    => 2,
      ),
   ),
   description => 'just mix em.  Ice is ok.',
);

my $w_c = Drink->new(
   name => 'Wes Collins',
   variant_of_drink_name => 'Tom Collins',
   variants => RSFaker->new(
      Drink->new( name => 'Geoff Collins' ),
   ),
   source => 'Weskers Manlone',
   links_to_drink_ingredients => RSFaker->new(
      Ingredient->new(
         ingredient_name => 'Tonic',
         unit_name => 'ounce',
         amount    => 4,
      ),
      Ingredient->new(
         ingredient_name => 'Gin',
         unit_name => 'ounce',
         amount    => 2,
      ),
      Ingredient->new(
         ingredient_name => 'Triple Sec',
         unit_name => 'ounce',
         amount    => 1,
      ),
   ),
   description => 'just mix em.  Ice is ok.',
);

subtest drink_as_markdown => sub {
   my $out;
   $out = <<'CRUMP';
## Gin and Tonic

## Ingredients

 * 2 ounces of Gin
 * 2 ounces of Tonic

## Description

just mix em.  Ice is ok.

CRUMP
   is(drink_as_markdown($g_t), $out, 'vanilla');

   $out = <<'CRUMP';
## Wes Collins

## Ingredients

 * 4 ounces of Tonic
 * 2 ounces of Gin
 * 1 ounce of Triple Sec

## Description

just mix em.  Ice is ok.

Variant of Tom Collins

Variants: Geoff Collins

Source: Weskers Manlone

CRUMP
   is(drink_as_markdown($w_c), $out, 'variant_of + variants + source');
};

my $l_w = Drink->new(
   name => 'Lol Collins',
   links_to_drink_ingredients => RSFaker->new(
      Ingredient->new(
         ingredient_name => 'Tonic',
         arbitrary_amount  => 'Bottle',
         notes => 'srsly, the whole bottle!',
      ),
   ),
   description => 'just mix em.  Ice is ok.',
);

subtest drink_as_data => sub {
   cmp_deeply(
      drink_as_data($l_w), {
         name => 'Lol Collins',
         description => 'just mix em.  Ice is ok.',
         source => undef,
         ingredients => [{
            arbitrary_amount => 'Bottle',
            notes => 'srsly, the whole bottle!',
            name => "Tonic",
         }],
      },
      'arbitrary_amount + notes',
   );

   cmp_deeply(
      drink_as_data($g_t), {
         name => 'Gin and Tonic',
         description => 'just mix em.  Ice is ok.',
         source => undef,
         ingredients => [{
            amount => 2,
            name => "Gin",
            unit => "ounce"
         }, {
            amount => 2,
            name => "Tonic",
            unit => "ounce"
         }],
      },
      'vanilla',
   );

   cmp_deeply(
      drink_as_data($w_c), {
         name => "Wes Collins",
         ingredients => [{
            amount => 4,
            name => "Tonic",
            unit => "ounce"
         }, {
            amount => 2,
            name => "Gin",
            unit => "ounce"
         }, {
            amount => 1,
            name => "Triple Sec",
            unit => "ounce"
         }],
         source => "Weskers Manlone",
         variant_of_drink => "Tom Collins",
         description => "just mix em.  Ice is ok.",
      },
      'variant_of + variants + source',
   );
};

use Devel::Dwarn;

subtest ingredient_as_data => sub {
   cmp_deeply(
      ingredient_as_data(Ingredient2->new(
         name => 'cola',
      )), {
         name => 'cola',
         description => undef
      },
      'vanilla',
   );

   cmp_deeply(
      ingredient_as_data(Ingredient2->new(
         name => 'cola',
         direct_kind_of_name => 'soda',
      )), {
         name => 'cola',
         description => undef,
         isa => 'soda',
      },
      'direct_kind_of',
   );
};

subtest single_item => sub {
   my $ran;
   my $found;
   single_item(
      sub { $ran = 1; $found = $_[0]->view },
      'foo',
      'bar',
      RSFaker->new(
         Item->new(
            view => 'lol',
         )
      ),
   );
   ok($ran, '"single" single_item ran');
   is($found, 'lol', 'correct thing passed to action');

   exits_nonzero {
      single_item(
         sub {}, 'foo', 'bar', RSFaker->new(),
      )
   } 'zero';

   exits_nonzero {
      single_item(
         sub {}, 'foo', 'bar', RSFaker->new(
            map Item->new( view => $_ ), 1, 2,
         ),
      )
   } 'many';
};

done_testing;

BEGIN {
   package Ingredient;

   use Moo;

   has $_ => (
      is => 'ro',
   ) for qw(ingredient_name arbitrary_amount amount unit_name notes );

   sub unit { $_[0]->unit_name }

   package Ingredient2;

   use Moo;

   has $_ => (
      is => 'ro',
   ) for qw( name description direct_kind_of_name );

   sub direct_kind_of { $_[0]->direct_kind_of_name }

   package RSFaker;

   use Moo;

   has guts => (
      is => 'ro',
      default => sub { [] },
   );

   sub BUILDARGS { shift; return { guts => [@_], } }

   sub all { @{$_[0]->guts} }
   sub count { scalar @{$_[0]->guts} }
   sub single { $_[0]->guts->[0] }
   sub cli_find { $_[0] }

   package Drink;

   use Moo;

   has $_ => (
      is => 'ro',
   ) for qw(
      name links_to_drink_ingredients variant_of_drink_name source description
   );

   sub variant_of_drink { $_[0]->variant_of_drink_name }

   has variants  => (
      is => 'ro',
      default => sub { RSFaker->new() },
   );

   package Item;

   use Moo;

   has view => (
      is => 'ro',
   );
}
