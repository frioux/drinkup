#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A 'stdout_is';

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

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

done_testing;

