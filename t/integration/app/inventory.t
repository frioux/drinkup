#!/usr/bin/env perl

use 5.16.0;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A 'stdout_is';

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

subtest 'help' => sub {
   my $result = test_app($app => [qw(inventory help)]);
   stdout_is($result, [
    'inventory.t <command>',
    '',
    'Available commands:',
    '',
    q(  commands: list the application's commands),
    q(      help: display a command's help screen),
    '',
    '       add: add ingredient to inventory',
    '        ls: list inventory',
    '        rm: remove ingredient from inventory'
   ]);
};

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

