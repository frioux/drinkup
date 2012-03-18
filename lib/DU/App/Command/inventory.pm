package DU::App::Command::inventory;

use 5.14.1;
use warnings;

use parent 'App::Cmd::Subdispatch';

use constant plugin_search_path => __PACKAGE__;

sub abstract { 'interact with inventory' }

sub usage_desc { 'du inventory $cmd' }

1;
