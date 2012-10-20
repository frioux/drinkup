package DU::App::Command::ingredient;

use 5.16.0;
use warnings;

use parent 'App::Cmd::Subdispatch';

use constant plugin_search_path => __PACKAGE__;

sub abstract { 'interact with ingredients' }

sub usage_desc { 'du ingredient $cmd' }

1;
