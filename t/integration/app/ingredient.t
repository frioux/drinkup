#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A 'stdout_is';

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

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

done_testing;

