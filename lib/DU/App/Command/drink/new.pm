package DU::App::Command::drink::new;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util;

sub abstract { 'create new drink' }

sub usage_desc { 'du drink new $drink' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $i = $self->app->app->schema->resultset('Ingredient')->create(
      DU::Util::edit_data({
         name => 'new ingredient',
         description => undef,
      })
   );

   say 'ingredient (' . $i->name . ') created';
}

1;


