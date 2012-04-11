package DU::App::Command::drink::new;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util qw(edit_data drink_as_markdown);

sub abstract { 'create new drink' }

sub usage_desc { 'du drink new $drink' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $i = $self->app->app->schema->create_drink(
      edit_data({
         description => 'Refreshing beverage for a hot day',
         name => 'Tom Collins',
         source => '500 Cocktails, p27',
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

   $i->discard_changes;

   print drink_as_markdown($i);
   say 'drink (' . $i->name . ') created';
}

1;

