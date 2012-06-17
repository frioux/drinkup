use inc::Module::Install;
use strict;
use warnings;

requires 'rlib';
requires 'DBIx::Class';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::Candy';
requires 'DBIx::Class::Helpers';
requires 'DBIx::Class::UnicornLogger';
requires 'IO::Compress::Xz';
requires 'App::Cmd';
requires 'YAML::Syck';
requires 'Test::More';

name        'Drinkup';
author      'Arthur Axel fREW Schmidt <frioux@gmail.com>';
abstract    'track booze.';
license     'gpl';
repository  'git://github.com/frioux/drinkup';

all_from    'lib/DU.pm';

install_script (qw|
  bin/dup
|);

tests_recursive();

auto_install();

WriteAll();
