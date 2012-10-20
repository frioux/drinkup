package DU::Schema::Result;

use 5.16.0;
use warnings;

use parent 'DBIx::Class::Core';

__PACKAGE__->load_components(qw{
   TimeStamp
   Helper::Row::NumifyGet
   Helper::Row::ToJSON
   Helper::Row::RelationshipDWIM
   Helper::Row::JoinTable
});

sub default_result_namespace { 'DU::Schema::Result' }

1;
