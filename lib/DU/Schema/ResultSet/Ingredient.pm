package DU::Schema::ResultSet::Ingredient;

use 5.14.1;
use warnings;

use parent 'DU::Schema::ResultSet';

sub cli_find {
   my $me = $_[0]->current_source_alias;
   $_[0]->search({ "$me.name" => $_[0]->_glob_to_like($_[1]) })
}

1;
