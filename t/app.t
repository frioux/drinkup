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

done_testing;
