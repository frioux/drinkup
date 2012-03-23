#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;

use DU::App;
local $ENV{PATH} = 't/editors:' . $ENV{PATH};

subtest 'drink' => sub {
   subtest 'ls' => sub {
      my $result = test_app('DU::App' => [qw(drink ls)]);
      my @out = split /\n/, $result->stdout;
      is_deeply \@out, [
         '## Tom Collins',
         '',
         '## Ingredients',
         '',
         ' * 4 shots of Club Soda',
         ' * 2 shots of Gin',
         ' * 1 shot of Lemon Juice',
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
         ' * 4 shots of Coca Cola',
         ' * 2 shots of Light Rum',
         ' * 1 shot of Lime Juice',
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
         ' * 4 shots of Coca Cola',
         ' * 2 shots of Dark Rum',
         ' * 1 shot of Lime Juice',
         ' * 3 drops of Vanilla Extract',
         '',
         '## Description',
         '',
         'A Delicious beverage of my own design',
         '',
         'Variant of Cuba Libre',
     ];
   };

   subtest 'new' => sub {
      local $ENV{EDITOR} = 'drink-new-1';
      my $result = test_app('DU::App' => [qw(drink new frew)]);
      my @out = split /\n/, $result->stdout;
      is_deeply \@out, [
         '## Awesome bevvy',
         '',
         '## Ingredients',
         '',
         ' * 4 shots of ice',
         '',
         '## Description',
         '',
         "YUMM",
         '',
         'drink (Awesome bevvy) created',
     ];
   };

   subtest 'rm' => sub {
      my $result = test_app('DU::App' => [qw(drink rm tom)]);
      is($result->stdout, "drink (Tom Collins) deleted\n", 'simple deletion works');
   };

   subtest 'edit' => sub {
      local $ENV{EDITOR} = 'drink-edit-1';
      my $result = test_app('DU::App' => [qw(drink edit frew)]);
      my @out = split /\n/, $result->stdout;
      is_deeply \@out, [
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
         '',
         'drink (Frewba Libre) updated',
     ];
   };
};

subtest 'ingredient' => sub {
   subtest 'new' => sub {
      local $ENV{EDITOR} = 'ingredient-new-1';
      my $result = test_app('DU::App' => [qw(ingredient new)]);
      my @out = split /\n/, $result->stdout;
      is_deeply \@out, [
         'ingredient (copper coins) created',
     ];
   };

   subtest 'ls' => sub {
   };

   subtest 'edit' => sub {
   };

   subtest 'rm' => sub {
   };
};

subtest 'inventory' => sub {
   subtest 'add' => sub {
   };

   subtest 'ls' => sub {
   };

   subtest 'rm' => sub {
   };
};

done_testing;
