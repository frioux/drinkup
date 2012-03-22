#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;

use DU::App;

subtest 'drink rm' => sub {
   my $result = test_app('DU::App' => [qw(drink rm tom)]);
   is($result->stdout, "drink (Tom Collins) deleted\n", 'simple deletion works');
};

subtest 'drink edit' => sub {
   local $ENV{PATH} = 't/editors:' . $ENV{PATH};
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

done_testing;
