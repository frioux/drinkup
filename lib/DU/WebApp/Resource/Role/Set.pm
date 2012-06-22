package DU::WebApp::Resource::Role::Set;

use Moo::Role;

requires 'render_item';
requires 'decode_json';
requires 'encode_json';

has set => (
   is => 'ro',
   required => 1,
);

has writable => (
   is => 'ro',
);

sub allowed_methods {
   [
      qw(GET HEAD),
      ( $_[0]->writable ) ? (qw(POST)) : ()
   ]
}

sub post_is_create { 1 }

sub create_path { "worthless" }

sub content_types_provided { [ {'application/json' => 'to_json'} ] }
sub content_types_accepted { [ {'application/json' => 'from_json'} ] }

sub to_json { $_[0]->encode_json([ map $_[0]->render_item($_), $_[0]->set->all ]) }

sub from_json {
   $_[0]->create_resource(
      $_[0]->decode_json(
         $_[0]->request->content
      )
   )
}

sub create_resource { $_[0]->set->create($_[1]) }

1;
