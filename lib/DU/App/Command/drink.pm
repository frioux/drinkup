package DU::App::Command::drink;

use 5.14.1;
use warnings;

use parent 'App::Cmd::Subdispatch';

use constant plugin_search_path => __PACKAGE__;

sub abstract { 'list ingredients' }

sub usage_desc { 'du drink' }

1;
