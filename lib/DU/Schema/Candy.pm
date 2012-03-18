package DU::Schema::Candy;

use parent 'DBIx::Class::Candy';

sub base { 'DU::Schema::Result' }
sub perl_version { 14 }
sub autotable { 1 }

1;
