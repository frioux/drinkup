package DU::App::Command::ingredient::new;

use 5.16.1;
use Moo;

extends 'DU::App::Command';
use DU::Util;

sub abstract { 'create new ingredient' }

sub usage_desc { 'du ingredient new' }

sub opt_spec {
   [ 'add-to-inventory|A',  'add new ingredient to inventory automatically' ],
}

sub execute {
   my ($self, $opt, $args) = @_;

   my $new = DU::Util::edit_data({
      name => 'new ingredient',
      description => undef,
      isa => undef,
   });

   if (my $isa = delete $new->{isa}) {
      $new->{kind_of_id} = $self->rs('Ingredient')->find_or_create({
         name => $isa,
      })->id
   }

   my $i = $self->rs('Ingredient')->create($new);

   say 'ingredient (' . $i->name . ') created';

   if ($opt->add_to_inventory) {
      $self
         ->rs('User')
         ->find_by_name('frew')
         ->add_to_inventory_items({ ingredient_id => $i->id });

      say 'ingredient (' . $i->name . ') added to inventory';
   }
}

1;

