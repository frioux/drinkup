package DU::WebApp::Resource::Drink;

use Moo;

use DU::Util 'drink_as_data';

extends 'Web::Machine::Resource';
with 'DU::Role::JsonEncoder';
with 'DU::WebApp::Resource::Role::Item';

sub render_item { drink_as_data($_[1]) }

1;
