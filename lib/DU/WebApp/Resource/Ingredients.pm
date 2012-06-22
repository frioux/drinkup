package DU::WebApp::Resource::Ingredients;

use Moo;

extends 'Web::Machine::Resource';
with 'DU::Role::JsonEncoder';
with 'DU::WebApp::Resource::Role::Set';

sub render_item {
   +{
      name => $_[1]->name,
      id   => $_[1]->id,
   }
}

1;
