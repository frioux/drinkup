package DU::Schema::ResultSet::User;

use 5.16.0;
use warnings;

use parent 'DU::Schema::ResultSet';

sub find_by_name {
   my $me = $_[0]->current_source_alias;
   $_[0]->single({ "$me.name" => $_[1] })
}

1;
