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
   my $result = test_app($app => [qw(drink help)]);
   stdout_is($result, [
    'drink.t <command>',
    '',
    'Available commands:',
    '',
    q(  commands: list the application's commands),
    q(      help: display a command's help screen),
    '',
    '      edit: edit drink',
    '        ls: list drinks',
    '       new: create new drink',
    '        rm: delete drink',
    '      show: show drink'
   ]);
};

subtest 'ls' => sub {
   my $result = test_app($app => [qw(drink ls)]);
   stdout_is($result, [
      '* Tom Collins',
      '* Cuba Libre',
      '* Frewba Libre',
   ]);

   $result = test_app($app => [qw(drink ls -G lib)]);
   stdout_is($result, [
      '* Cuba Libre',
      '* Frewba Libre',
   ]);

   $result = test_app($app => [qw(drink ls -g), '??ba libre']);
   stdout_is($result, [
      '* Cuba Libre',
   ]);

   $result = test_app($app => [qw(drink ls -s)]);
   stdout_is($result, [
      '* Tom Collins',
   ]);

   $result = test_app($app => [qw(drink ls -n)]);
   stdout_is($result, [
      '* Cuba Libre',
      '* Frewba Libre',
   ]);

   $result = test_app($app => [qw(drink ls -a)]);
   stdout_is($result, []);

   $result = test_app($app => [qw(drink ls -e 1)]);
   stdout_is($result, [
      '* Tom Collins',
   ]);
};

subtest 'new' => sub {
   local $ENV{EDITOR} = 'drink-new-1';
   my $result = test_app($app => [qw(drink new -Y frew)]);
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
      '',
      'drink (Awesome bevvy) created',
   ]);

   local $ENV{EDITOR} = 'drink-new-2';
   $result = test_app($app => [qw(drink new -Yb), 'Awesome bevvy']);
   stdout_is($result, [
      '## Awesome bevvy2',
      '',
      '## Ingredients',
      '',
      ' * 5 ounces of ice',
      '',
      '## Description',
      '',
      "YUMM",
      '',
      q(Source: Boy's Life),
      '',
      '',
      'drink (Awesome bevvy2) created',
   ]);

   local $ENV{EDITOR} = 'drink-new-recipe-1';
   $result = test_app($app => [qw(drink new stuplidly-ignored)]);
   stdout_is($result, [
      '## Blood Wallet',
      '',
      '## Ingredients',
      '',
      ' * 1 ounce of Wallet',
      ' * 2 tablespoons of Blood',
      '',
      '## Description',
      '',
      'This is a thing from a song by Godspeed! You Black Emperor.',
      '',
      q(I'm not actually much of a fan.),
      '',
      q(Source: my brain, sector 5),
      '',
      '',
      'drink (Blood Wallet) created',
   ]);
};

subtest 'new --based_on' => sub {
   local $ENV{EDITOR} = 'drink-new-based-on';
   my $result = test_app($app => [qw(drink new --from_yaml --based_on), 'Awesome bevvy']);
   stdout_is($result, [
      '## silly new name',
      '',
      '## Ingredients',
      '',
      ' * 4 ounces of ice',
      '',
      '## Description',
      '',
      "YUMM",
      '',
      q(Variant of Awesome bevvy),
      '',
      q(Source: Boy's Life),
      '',
      '',
      'drink (silly new name) created',
   ]);
};

subtest 'rm' => sub {
   my $result = test_app($app => [qw(drink rm), 'tom*']);
   stdout_is($result, ["drink (Tom Collins) deleted"], 'simple deletion works');
};

subtest 'edit' => sub {
   local $ENV{EDITOR} = 'drink-edit-1';
   my $result = test_app($app => [qw(drink edit -Y), 'frewba libre']);
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


   my $app = A->app;

   local $ENV{EDITOR} = 'drink-edit-recipe-1';
   $result = test_app($app => [qw(drink edit), 'cuba libre']);
   stdout_is($result, [
      '## Face Mask',
      '',
      '## Ingredients',
      '',
      ' * 1 ounce of plastic',
      ' * 2 teaspoons of humanish rubber',
      '',
      '## Description',
      '',
      "It's a mask of your own face.  Could a halloween mask",
      'be any better than that?',
      '',
      'Variants: Frewba Libre',
      '',
      'Source: my brain, sector 6',
      '',
      '',
      'drink (Face Mask) updated',
   ]);
};

subtest 'show' => sub {
   my $result = test_app($app => [qw(drink show), 'frewba libre']);
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
   ]);
};

done_testing;

