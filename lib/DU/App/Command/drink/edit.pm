package DU::App::Command::drink::edit;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util 'drink_as_markdown', 'drink_as_data';

sub abstract { 'edit drink' }

sub usage_desc { 'du drink edit $drink' }

sub execute {
   my ($self, $opt, $args) = @_;

   DU::Util::single_item(sub {
      my $data = DU::Util::edit_data(drink_as_data($_[0]));

      my $basic = {
         description => $data->{description},
         source      => $data->{source},
         variant_of_drink_id => undef,
      };
      if (my $v = $data->{variant_of_drink}) {
         DU::Util::single_item(sub {
            $basic->{variant_of_drink_id} = $_[0]->id
         }, 'drink variant', $v, $self->app->app->schema->resultset('Drink'));
      }

      $_[0]->update($basic);

      $_[0]->names->delete;
      $_[0]->add_to_names({ name => $data->{name}, order => 1 });

      $_[0]->links_to_drink_ingredients->delete;
      for (@{$data->{ingredients}}) {
         my @unit;
         if ($_->{unit}) {
            my $unit_id = $self->app->app->schema->resultset('Unit')
               ->search({ name => $_->{unit} })
               ->get_column('id')
               ->single
               or die "unknown unit $_->{unit} used";
            @unit = ( unit_id => $unit_id )
         }
         $_[0]->links_to_drink_ingredients->create(
            +{
               ( $_->{arbitrary_volume}
                  ? ( arbitrary_volume => $_->{arbitrary_volume} )
                  : ()
               ),
               ( $_->{unit}
                  ? (
                     @unit,
                     amount => $_->{amount},
                  )
                  : ()
               ),
               ( $_->{notes}  ? ( notes  => $_->{notes}  ) : () ),
               ingredient => { name => $_->{name} },
            }
         );
      }
      print drink_as_markdown($_[0]);
      say 'drink (' . $_[0]->name . ') updated';
   }, 'drink', $args->[0], $self->app->app->schema->resultset('Drink'));
}

1;

