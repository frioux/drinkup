#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use App::Cmd::Tester;
use Data::Dumper::Concise;
use File::Temp 'tempfile';

use lib 't/lib';

use A;

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

subtest help => sub {
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
};

subtest 'drink' => sub {
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
};

subtest 'ingredient' => sub {
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
         ' * ice',
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
};

subtest 'inventory' => sub {
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
};

subtest 'maint' => sub {
   my $app1 = DU::App->new({
      connect_info => {
         dsn => 'dbi:SQLite::memory:',
         on_connect_do => 'PRAGMA foreign_keys = ON',
      },
   });
   my $app2 = DU::App->new({
      connect_info => {
         dsn => 'dbi:SQLite::memory:',
         on_connect_do => 'PRAGMA foreign_keys = ON',
      },
   });

   subtest 'install' => sub {
      my $result = test_app($app1 => [qw(maint install),]);
      stdout_is($result, [ 'done' ]);
      is($app1->schema->resultset('Drink')->count, 3, 'drinks correctly seeded');
   };

   subtest 'install --no-seeding' => sub {
      my $result = test_app($app2 => [qw(maint install --no-seeding),]);
      stdout_is($result, [ 'done' ]);
      is($app2->schema->resultset('Drink')->count, 0, 'drinks correctly unseeded');

      $app2->schema->resultset('Unit')->populate([
         [qw(name gills)],
         [ounce      => 1 / 4         ] ,
         [tablespoon => 1 / 4 / 2     ] ,
         [teaspoon   => 1 / 4 / 2 / 3 ] ,
         [dash       => undef         ] ,
      ]);

   };

   my (undef, $filename) = tempfile(OPEN => 0);
   subtest 'export' => sub {
      ok(!-f 'test-export.tar.xz', 'no export yet');
      my $result = test_app($app1 => [qw(maint export), $filename]);
      stdout_is($result, [ 'done' ]);
      ok(-f "$filename.tar.xz", 'export created');
   };
   subtest 'import' => sub {
      my $result = test_app($app2 => [qw(maint import), $filename]);
      stdout_is($result, [ 'done' ]);
      unlink "$filename.tar.xz";
   };
};

done_testing;

sub stdout_is {
   my ( $result, $expected, $reason ) = @_;

   my @out = split /\n/, $result->stdout;
   local $Test::Builder::Level = $Test::Builder::Level + 1;
   is_deeply(\@out, $expected, $reason || ()) or diag(Dumper({
      stdout => \@out,
      stderr => [split /\n/, $result->stderr],
      error  => $result->error,
   }))
}
