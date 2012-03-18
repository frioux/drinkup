package DU::Schema::ResultSet::Drink;

use 5.14.1;
use warnings;

use parent 'DU::Schema::ResultSet';

sub cli_find {
   $_[0]->search({
      "names.name" => { -like => "%$_[1]%" }
   }, {
      join => 'names',
   })
}

1;
