package DU::App::Command::drink;

use 5.14.1;
use warnings;

use parent 'App::Cmd::Subdispatch';

use constant plugin_search_path => __PACKAGE__;

sub abstract { 'interact with drinks' }

sub usage_desc { 'du drink $cmd' }

1;
