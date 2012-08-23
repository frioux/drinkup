package DU::Schema::ResultSet::Ingredient;

use 5.16.1;
use warnings;

use parent 'DU::Schema::ResultSet';

sub cli_find {
   my $me = $_[0]->current_source_alias;
   $_[0]->search({ "$me.name" => $_[0]->_glob_to_like($_[1]) })
}

sub find_by_name {
   my $me = $_[0]->current_source_alias;
   $_[0]->single({ "$me.name" => $_[1] })
}

1;
