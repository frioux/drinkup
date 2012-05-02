package DU::Schema;

use parent 'DBIx::Class::Schema';
use Scalar::Util 'blessed';

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

   my @variant;

   if (my $vn = $args->{variant_of_drink}) {
      my $v;
      if (blessed $vn) {
         $v = $vn;
      } else {
         $v = $self->resultset('Drink')->find_by_name($vn)
            or die "no such drink $vn";
      }
      @variant = ( variant_of_drink_id => $v->id )
   }

   my @links = map {
      my @unit;
      if ($_->{unit}) {
         my $unit_id = $self->resultset('Unit')
            ->search({ name => $_->{unit} })
            ->get_column('id')
            ->single
            or die "unknown unit $_->{unit} used";
         @unit = ( unit_id => $unit_id )
      }

      +{
         ( $_->{arbitrary_amount}
            ? ( arbitrary_amount => $_->{arbitrary_amount} )
            : ()
         ),
         @unit,

         ( $_->{notes}  ? ( notes  => $_->{notes}  ) : () ),
         ( $_->{amount}  ? ( amount  => $_->{amount}  ) : () ),
         ( $_->{amount}  ? ( amount  => $_->{amount}  ) : () ),
         ingredient => { name => $_->{name} },
      }
   }  @{$args->{ingredients}};
   $self->resultset('Drink')->create({
      description => $args->{description},
      source => $args->{source},
      @variant,
      names => [{
         name => $args->{name},
         order => 1,
      }],
      links_to_drink_ingredients => \@links,
   })
}

use DBIx::Class::UnicornLogger;
my $pp = DBIx::Class::UnicornLogger->new({
   tree => { profile => 'console' },
   profile => 'console'
});

sub connection {
   my $self = shift;

   my $ret = $self->next::method(@_);

   $self->storage->debugobj($pp);

   $ret
}

1;
