#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;
use Data::Dumper::Concise;

use lib 't/lib';

use A;

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

subtest 'drink' => sub {
   subtest 'ls' => sub {
      my $result = test_app($app => [qw(drink ls)]);
      stdout_is($result, [
         '## Tom Collins',
         '',
         '## Ingredients',
         '',
         ' * 4 ounces of Club Soda',
         ' * 2 ounces of Gin',
         ' * 1 ounce of Lemon Juice',
         ' * 1 teaspoon of Simple Syrup',
         '',
         '## Description',
         '',
         'Refreshing beverage for a hot day',
         '',
         '## Cuba Libre',
         '',
         '## Ingredients',
         '',
         ' * 4 ounces of Coca Cola',
         ' * 2 ounces of Light Rum',
         ' * 1 ounce of Lime Juice',
         '',
         '## Description',
         '',
         'Delicious drink all people should try',
         '',
         'Variants: Frewba Libre',
         '',
         '## Frewba Libre',
         '',
         '## Ingredients',
         '',
         ' * 4 ounces of Coca Cola',
         ' * 2 ounces of Dark Rum',
         ' * 1 ounce of Lime Juice',
         ' * 3 drops of Vanilla Extract',
         '',
         '## Description',
         '',
         'A Delicious beverage of my own design',
         '',
         'Variant of Cuba Libre',
      ]);
   };

   subtest 'new' => sub {
      local $ENV{EDITOR} = 'drink-new-1';
      my $result = test_app($app => [qw(drink new frew)]);
      stdout_is($result, [
         '## Awesome bevvy',
         '',
         '## Ingredients',
         '',
         ' * 4 ounces of ice',
         '',
         '## Description',
         '',
         "YUMM",
         '',
         q(Source: Boy's Life),
         '',
         'drink (Awesome bevvy) created',
      ]);
   };

   subtest 'rm' => sub {
      my $result = test_app($app => [qw(drink rm), 'tom*']);
      stdout_is($result, ["drink (Tom Collins) deleted"], 'simple deletion works');
   };

   subtest 'edit' => sub {
      local $ENV{EDITOR} = 'drink-edit-1';
      my $result = test_app($app => [qw(drink edit), 'frewba libre']);
      stdout_is($result, [
         '## Frewba Libre',
         '',
         '## Ingredients',
         '',
         '',
         '## Description',
         '',
         "A Delicious beverage of frew's own design",
         '',
         'Variant of Cuba Libre',
         '',
         'Source: TV Guide wtf?',
         '',
         '',
         'drink (Frewba Libre) updated',
      ]);
   };
};

subtest 'ingredient' => sub {
   subtest 'new' => sub {
      local $ENV{EDITOR} = 'ingredient-new-1';
      my $result = test_app($app => [qw(ingredient new)]);
      stdout_is($result, [ 'ingredient (copper coins) created' ]);
   };

   subtest 'ls' => sub {
      my $result = test_app($app => [qw(ingredient ls)]);
      stdout_is($result, [
         '## Ingredients',
         ' * Club Soda',
         ' * Gin',
         ' * Lemon Juice',
         ' * Simple Syrup',
         ' * Coca Cola',
         ' * Light Rum',
         ' * Lime Juice',
         ' * Dark Rum',
         ' * Vanilla Extract',
         ' * ice',
         ' * coin',
         ' * copper coins',
      ]);
   };

   subtest 'edit' => sub {
      local $ENV{EDITOR} = 'ingredient-edit-1';
      my $result = test_app($app => [qw(ingredient edit), 'lime *']);
      stdout_is($result, [
         'ingredient (plastic buttons) updated',
      ]);
   };

   subtest 'rm' => sub {
      my $result = test_app($app => [qw(ingredient rm), 'simple syrup']);
      stdout_is($result, [ 'ingredient (Simple Syrup) deleted' ]);
   };
};

subtest 'inventory' => sub {
   subtest 'add' => sub {
      my $result = test_app($app => [qw(inventory add), '* cola']);
      stdout_is($result, [ 'ingredient (Coca Cola) added to inventory' ]);
   };

   subtest 'ls' => sub {
      my $result = test_app($app => [qw(inventory ls)]);
      stdout_is($result, [
         '## Inventory',
         ' * Club Soda',
         ' * Gin',
         ' * Lemon Juice',
         ' * Coca Cola',
      ]);
   };

   subtest 'rm' => sub {
      my $result = test_app($app => [qw(inventory rm), 'lemon juice']);
      stdout_is($result, [ 'ingredient (Lemon Juice) removed from inventory' ]);
   };
};

done_testing;

sub stdout_is {
   my ( $result, $expected, $reason ) = @_;

   my @out = split /\n/, $result->stdout;
   local $Test::Builder::Level = $Test::Builder::Level + 1;
   is_deeply(\@out, $expected, $reason || ()) or diag(Dumper({
      stdout => \@out,
      stderr => [split /\n/, $result->stderr],
   })), die 'so long cruel world';
}
