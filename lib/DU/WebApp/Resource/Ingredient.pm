package DU::WebApp::Resource::Ingredient;

use Moo;

use DU::Util 'ingredient_as_data';

extends 'Web::Machine::Resource';
with 'DU::Role::JsonEncoder';
with 'DU::WebApp::Resource::Role::Item';

sub render_item { ingredient_as_data($_[1]) }

1;
