package DU::App::Command::maint;

use 5.16.0;
use warnings;

use parent 'App::Cmd::Subdispatch';

use constant plugin_search_path => __PACKAGE__;

sub abstract { '' }

sub usage_desc { 'du maint $cmd' }

1;
