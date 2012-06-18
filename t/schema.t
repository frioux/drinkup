#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Test::More;
use Test::Deep;

use lib 't/lib';

use A;
use_ok 'DU::Schema';

my $s = DU::Schema->connect({
   dsn => 'dbi:SQLite::memory:',
   quote_names => 1,
});

A->_deploy_schema($s);

$s->resultset('Unit')->populate([
   [qw(name gills)],
   [ounce      => 1 / 4         ] ,
   [tablespoon => 1 / 4 / 2     ] ,
   [teaspoon   => 1 / 4 / 2 / 3 ] ,
   [dash       => undef         ] ,
]);

my @correct = ({
   name => 'Club Soda',
   unit => 'ounce',
   amount => 4,
}, {
   name => 'Gin',
   unit => 'ounce',
   amount => 2,
}, {
   name => 'Lemon Juice',
   unit => 'ounce',
   amount => 1,
}, {
   name => 'Simple Syrup',
   unit => 'teaspoon',
   amount => 1,
});

my $tom_collins = $s->create_drink({
   description => 'Refreshing beverage for a hot day',
   name => 'Tom Collins',
   ingredients => \@correct,
});

is $tom_collins->name, 'Tom Collins', 'Name of drink set correctly';

my $links =$tom_collins->links_to_drink_ingredients->search(undef, {
   order_by => 'ingredient.name',
   prefetch => 'ingredient',
});

my $i = 0;
for ($links->all) {
   is $_->ingredient->name, $correct[$i]->{name}, "${i}th name correct";
   is $_->amount, $correct[$i]->{amount}, "${i}th amount correct";
   is $_->unit->name, $correct[$i]->{unit}, "${i}th unit correct";

   $i++;
}
is $links->slice(0)->single->ingredient->name, 'Club Soda';

subtest kinds => sub {
   my $ings = $s->resultset('Ingredient');

   my $rum = $ings->create({ name => 'Rum' });
   my $dark_rum = $rum->direct_kinds->create({ name => 'Dark Rum' });
   $dark_rum->direct_kinds->create({ name => q(Myers's Jamaican Rum) });
   $rum->direct_kinds->create({ name => 'Gold Rum' });
   $rum->direct_kinds->create({ name => 'Black Rum' });
   $rum->direct_kinds->create({ name => 'Spiced Rum' });

   is( $rum->direct_kinds->count, 4, 'direct kinds all created');
   is( $rum->kinds->count, 4 + 1 + 1, 'kinds count is correct');
   is( $dark_rum->direct_kind_of->name, 'Rum', 'direct_kind_of is correct for dark rum');
   $rum->discard_changes; # why do I have to do this?
   ok(!$rum->direct_kind_of, 'Rum is not a kind of anything');

   my $liquor = $ings->create({ name => 'Liquor' });
   $rum->kind_of_id($liquor->id);
   $rum->update;
   $rum->discard_changes;
   $dark_rum->discard_changes;
   is( $liquor->kinds->count, 4 + 1 + 1 + 1, 'kinds count for liquor is correct');
   is( $dark_rum->kind_of->count, 3, 'dark rum is dark rum, rum, and liquor');
};

subtest searches => sub {
   my $s = DU::Schema->connect({
      dsn => 'dbi:SQLite::memory:',
      quote_names => 1,
   });
   A->_deploy_schema($s);
   A->_populate_schema($s);

   my $d = $s->resultset('Drink');
   my $f = $s->resultset('User')->first;

   $f->add_to_ingredients($_)
      for $s->resultset('Ingredient')->search({
         name => ['Simple Syrup', 'Vanilla Extract' ],
      })->all;

   cmp_deeply(
      [ sort map $_->name, $d->none_by_user_inventory($f)->all ],
      [ 'Cuba Libre' ],
      'none'
   );

   cmp_deeply(
      [ sort map $_->name, $d->some_by_user_inventory($f)->all ],
      [ 'Frewba Libre', 'Tom Collins' ],
      'some'
   );

   $f->inventory_items->search({
      'ingredient.name' => 'Lemon Juice',
   }, {
      join => 'ingredient',
   })->delete;

   my $lemon_juice = $s->resultset('Ingredient')->search({ name => 'Lemon Juice' })
      ->single;

   my $sl = $lemon_juice->direct_kinds->create({ name => 'Sunkist Lemon Juice' });

   cmp_deeply(
      [ sort map $_->name, $d->every($f)->all ],
      [ ],
      'every'
   );
   $f->add_to_ingredients($sl);

   cmp_deeply(
      [ sort map $_->name, $d->every($f)->all ],
      [ 'Tom Collins', ],
      'every (post kind_of addition)'
   );
};

done_testing;
