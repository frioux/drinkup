use 5.16.0;
use warnings;

use Test::More;
use Time::HiRes qw(gettimeofday tv_interval);
use List::Util 'shuffle';

use lib 't/lib';

use A;
use DU::Schema;
my $s = DU::Schema->connect({
   dsn => 'dbi:SQLite::memory:',
   quote_names => 1,
});
A->_deploy_schema($s);

my $amount_of_ingredients = $ENV{DU_TEST_INGREDIENTS} || 1000;
my $amount_of_drinks = $ENV{DU_TEST_DRINKS} || 100;
my @ingredients_per_drink = split /,/, $ENV{DU_TEST_INGREDIENTS_PER_DRINK} || "3,3,3,3,3,3,3,5,5,6,6,7,7";
my $ingredients_on_hand = $ENV{DU_INGREDIENTS_ON_HAND} || 70;

tt(
   "populating $amount_of_ingredients ingredients" => sub {
      $s->resultset('Ingredient')->create({
         name => "ing$_",
      }) for 1..$amount_of_ingredients;
   },
);

is(
   $s->resultset('Ingredient')->count,
   $amount_of_ingredients,
   "$amount_of_ingredients ingredients generated"
);

my @ingredients = $s->resultset('Ingredient')->all;

my $user = $s->resultset('User')->create({ name => 'frew' });

tt(
   "putting $ingredients_on_hand ingredients in inventory" => sub {
      $user->add_to_ingredients($_)
         for (shuffle @ingredients)[1..$ingredients_on_hand];
   }
);

is(
   $user->ingredients->count,
   $ingredients_on_hand,
   "$ingredients_on_hand ingredients added to inventory",
);

$s->resultset('Unit')->populate([
   [qw(name gills)],
   [ounce      => 1 / 4 ] ,
]);

tt(
   "creating $amount_of_drinks drinks" => sub {
      $s->create_drink({
         name => "dri$_",
         description => "desc$_",
         ingredients => [map +{
            name => $_->name,
            amount => 1,
            unit => 'ounce',
         }, (shuffle @ingredients)[1..$ingredients_per_drink[rand scalar @ingredients_per_drink]]],
      }) for 1..$amount_of_drinks
   }
);

for my $method (qw(none_by_user_inventory some_by_user_inventory every_by_user)) {
   for my $retrieval (qw(count all)) {
      tt( "$method $retrieval" => sub {
         $s->resultset('Drink')->$method($user)->$retrieval
      });
   }
}

tt( "nearly count" => sub {
   $s->resultset('Drink')->nearly_by_user($user, 1)->count
});

tt( "nearly all" => sub {
   $s->resultset('Drink')->nearly_by_user($user, 1)->all
});

sub tt {
   my ($comment, $code) = @_;
   note $comment;
   my $t0 = [gettimeofday];
   $code->();
   my $elapsed = tv_interval($t0, [gettimeofday]);
   note sprintf "%0.03f seconds elapsed", $elapsed;
}

done_testing;
