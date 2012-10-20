#!/usr/bin/env perl

package DU::WebApp;

use 5.16.0;
use Web::Simple;

use DU::WebApp::Machine;
use Config::ZOMG;
use Path::Class::File;

use DU::Schema;
use Module::Load;
my $schema = DU::Schema->connect({
   quote_names => 1,
   %{Config::ZOMG->new(
      name => 'drinkup',
      path => Path::Class::File->new(__FILE__)->dir->parent->parent->stringify,
   )->load->{connect_info}}
});

sub wm {
   load $_[0];
   DU::WebApp::Machine->new(
      resource => $_[0],
      debris   => $_[1],
   )->to_app;
}

sub dispatch_request {
  sub (/drinks) { [ 301, [ 'Location', '/drinks/' ], [ 'nt bro' ] ] },
  sub (/drinks/...) {
    my $set = $schema->resultset('Drink');
    sub (/data/*) {
       wm('DU::WebApp::Resource::Drink', {
         item     => $set->find($_[1]),
         writable => 1,
       })
    },
    sub (/find_by_name + ?name=) {
       wm('DU::WebApp::Resource::Drink', { item => $set->find_by_name($_[1]) })
    },
    sub (/search_by_name + ?name=) {
       wm('DU::WebApp::Resource::Drinks', { set => $set->cli_find($_[1]) })
    },
    sub (/with_some_ingredients + ?@ingredient_id=) {
       wm('DU::WebApp::Resource::Drinks', { set => $set->some($_[1]) })
    },
    sub (/with_only_ingredients + ?@ingredient_id~&missing_greater_than~&missing_less_than~) {
       wm('DU::WebApp::Resource::Drinks', {
         set => $set->ineq_by_ingredient_id($_[1], $_[2] || 0, $_[3] || 0)
       })
    },
    sub (/without_ingredients + ?@ingredient_id=) {
       wm('DU::WebApp::Resource::Drinks', { set => $set->none_by_ingredient_id($_[1]) })
    },
    sub (/) {
       wm('DU::WebApp::Resource::Drinks', {
         set      => $set,
         writable => 1,
       })
    },
  },

  sub (/ingredients) { [ 301, [ 'Location', '/ingredients/' ], [ 'nt bro' ] ] },
  sub (/ingredients/...) {
    my $set = $schema->resultset('Ingredient');
    sub (/data/*) {
       wm('DU::WebApp::Resource::Ingredient', { item => $set->find($_[1]) })
    },
    sub (/find_by_name + ?name=) {
       wm('DU::WebApp::Resource::Ingredient', { item => $set->find_by_name($_[1]) })
    },
    sub (/search_by_name + ?name=) {
       wm('DU::WebApp::Resource::Ingredients', { set => $set->cli_find($_[1]) })
    },
    sub (/) {
       wm('DU::WebApp::Resource::Ingredients', { set => $set })
    },
  },

  sub () {
    [ 405, [ 'Content-type', 'text/plain' ], [ 'Method not allowed' ] ]
  }
}

DU::WebApp->run_if_script;
