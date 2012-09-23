#!/usr/bin/env perl

use 5.16.1;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A 'stdout_is';

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

subtest 'help' => sub {
   my $result = test_app($app => [qw(ingredient help)]);
   stdout_is($result, [
    'ingredient.t <command>',
    '',
    'Available commands:',
    '',
    q(  commands: list the application's commands),
    q(      help: display a command's help screen),
    '',
    '      edit: edit ingredient',
    '        ls: list ingredients',
    '       new: create new ingredient',
    '        rm: delete ingredient',
    '      show: show ingredient',
   ]);
};

subtest 'new' => sub {
   local $ENV{EDITOR} = 'ingredient-new-1';
   my $result = test_app($app => [qw(ingredient new)]);
   stdout_is($result, [ 'ingredient (copper coins) created' ], 'with isa');

   local $ENV{EDITOR} = 'ingredient-new-2';
   $result = test_app($app => [qw(ingredient new)]);
   stdout_is($result, [ 'ingredient (metal coins) created' ], 'without isa');

   local $ENV{EDITOR} = 'ingredient-new-3';
   $result = test_app($app => [qw(ingredient new --add-to-inventory)]);
   stdout_is($result, [
      'ingredient (Flesh) created',
      'ingredient (Flesh) added to inventory',
   ], '--add-to-inventory');
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
      ' * metal coins',
      ' * Flesh',
   ]);
};

subtest 'edit' => sub {
   local $ENV{EDITOR} = 'ingredient-edit-1';
   my $result = test_app($app => [qw(ingredient edit), 'lime *']);
   stdout_is($result, [
      'ingredient (plastic buttons) updated',
   ], 'with isa');

   local $ENV{EDITOR} = 'ingredient-edit-2';
   $result = test_app($app => [qw(ingredient edit), 'plastic buttons']);
   stdout_is($result, [
      'ingredient (plastic buttons) updated',
   ], 'without isa');
};

subtest 'rm' => sub {
   my $result = test_app($app => [qw(ingredient rm), 'simple syrup']);
   stdout_is($result, [ 'ingredient (Simple Syrup) deleted' ]);
};

subtest 'show' => sub {
   my $result = test_app($app => [qw(ingredient show), 'dark rum']);
   stdout_is($result, [
      '## Dark Rum',
      '',
      'Kind of: Dark Rum',
      'Kinds: Dark Rum',
   ]);
};

done_testing;

