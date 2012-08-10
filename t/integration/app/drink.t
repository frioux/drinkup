#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A 'stdout_is';

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

subtest 'ls' => sub {
   my $result = test_app($app => [qw(drink ls)]);
   stdout_is($result, [
      '* Tom Collins',
      '* Cuba Libre',
      '* Frewba Libre',
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
      '',
      'drink (Awesome bevvy) created',
   ]);
};

subtest 'new --based_on' => sub {
   local $ENV{EDITOR} = 'drink-new-based-on';
   my $result = test_app($app => [qw(drink new --based_on), 'Awesome bevvy']);
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

done_testing;

