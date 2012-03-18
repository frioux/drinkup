package DU::App::Command::drink;

use 5.14.1;
use warnings;

use parent 'App::Cmd::Subdispatch';

sub abstract { 'list ingredients' }

sub usage_desc { 'du drink' }

1;
