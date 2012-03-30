package DU::Schema::ResultSet::Drink;

use 5.14.1;
use warnings;

use parent 'DU::Schema::ResultSet';

sub cli_find {
   $_[0]->search({
      'names.name' => $_[0]->_glob_to_like($_[1]),
   }, {
      join => 'names',
   })
}

1;
