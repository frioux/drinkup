package DU::App::Command::ingredient::new;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util;

sub abstract { 'create new ingredient' }

sub usage_desc { 'du ingredient new' }

sub execute {
   my ($self, $opt, $args) = @_;

   my $new = DU::Util::edit_data({
      name => 'new ingredient',
      description => undef,
      isa => undef,
   });

   if (my $isa = delete $new->{isa}) {
      $new->{kind_of_id} = $self->app->app->schema->resultset('Ingredient')->find_or_create({
         name => $isa,
      })->id
   }

   my $i = $self->app->app->schema->resultset('Ingredient')->create($new);

   say 'ingredient (' . $i->name . ') created';
}

1;

