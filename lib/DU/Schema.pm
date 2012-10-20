package DU::Schema;

use 5.16.0;
use warnings;

use parent 'DBIx::Class::Schema';

our $VERSION = 2;

__PACKAGE__->load_namespaces(
   default_resultset_class => 'ResultSet',
);

sub create_drink { $_[0]->resultset('Drink')->create($_[1]) }

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
