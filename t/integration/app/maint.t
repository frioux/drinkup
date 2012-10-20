#!/usr/bin/env perl

use 5.16.0;
use warnings;

use Test::More;
use App::Cmd::Tester;
use File::Temp 'tempfile';

use lib 't/lib';

use A 'stdout_is';

my $app = A->app;

local $ENV{PATH} = 't/editors:' . $ENV{PATH};

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

subtest 'migrate' => sub {
   my $result = test_app($app1 => [qw(maint migrate),]);
   stdout_is($result, [ 'done' ]);
   is($app1->schema->resultset('Unit')->count, 4, 'units correctly seeded');
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

done_testing;

