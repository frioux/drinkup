package DU::Schema;

use parent 'DBIx::Class::Schema';

use Carp 'croak';

our $VERSION = 1;

__PACKAGE__->load_namespaces(
   default_resultset_class => 'ResultSet',
);

sub create_drink {
   my ($self, $args) = @_;

   croak 'ingredients arrayref is required!'
      unless $args->{ingredients} and
         ref $args->{ingredients} eq 'ARRAY';

   $self->resultset('Drink')->create({
      description => $args->{description},
      names => [{
         name => $args->{name},
         order => 1,
      }],
      links_to_drink_ingredients => [
         map {
            +{
               ( $_->{arbitrary_volume}
                  ? ( arbitrary_volume => $_->{arbitrary_volume} )
                  : ()
               ),
               ( $_->{volume} ? ( volume => $_->{volume} ) : () ),
               ( $_->{notes}  ? ( notes  => $_->{notes}  ) : () ),
               ingredient => { name => $_->{name} },
            }
         }  @{$args->{ingredients}}],
   })
}

1;
