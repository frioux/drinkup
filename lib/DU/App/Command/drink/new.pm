package DU::App::Command::drink::new;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util;

sub abstract { 'create new drink' }

sub usage_desc { 'du drink new $drink' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $i = $self->app->app->schema->create_drink(
      DU::Util::edit_data({
         description => 'Refreshing beverage for a hot day',
         name => 'Tom Collins',
         ingredients => [{
            name => 'Club Soda',
            volume => 1,
         }, {
            name => 'Gin',
            volume => .5,
         }, {
            name => 'Lemon Juice',
            volume => .25,
         }, {
            name => 'Simple Syrup',
            volume => 1 / 24,
         }],
      })
   );

   say 'drink (' . $i->name . ') created';
}

1;


