#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;

use lib 't/lib';

use A 'stdout_is';

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

local $TODO = q(App::Cmd can't test help for subcommands?);
my $result = test_app($app => [qw(drink help)]);
stdout_is($result, [
   'app.t <command>',
   '',
   'Available commands:',
   '',
   q(  commands: list the application's commands),
   q(      help: display a command's help screen),
   '',
   '     drink: interact with drinks',
   'ingredient: interact with ingredients',
   ' inventory: interact with inventory',
   '     maint: ',
   '',
]);

done_testing;
