package DU::App::Command::drink::new;

use 5.16.1;
use Moo;

extends 'DU::App::Command';
use DU::Util qw(edit_data drink_as_data single_item drink_as_markdown);

sub abstract { 'create new drink' }

sub usage_desc { 'du drink new $drink' }

sub opt_spec {
   [ 'based_on|b=s',  'the drink to base the new drink on' ],
}

sub execute {
   my ($self, $opt, $args) = @_;

   my $create;
   if (my $b = $opt->based_on) {
      single_item(sub {
         $create = drink_as_data($_[0]);
         $create->{variant_of_drink} = $_[0]->name;
      }, 'drink', $b, $self->rs('Drink'))
   } else {
      $create = {
         description => 'Refreshing beverage for a hot day',
         name => 'Tom Collins',
         source => '500 Cocktails, p27',
         ingredients => [{
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
            unit => 'tablespoon',
            amount => 1,
         }],
      }
   }

   my $i = $self->schema->create_drink(
      edit_data($create)
   );

   $i->discard_changes;

   print drink_as_markdown($i);
   say 'drink (' . $i->name . ') created';
}

1;

