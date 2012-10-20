package DU::Schema::ResultSet::InventoryItem;

use 5.16.0;
use warnings;

use parent 'DU::Schema::ResultSet';

sub cli_find {
   $_[0]->search({
      "ingredient.name" => $_[0]->_glob_to_like($_[1]),
   }, {
      join => 'ingredient',
   })
}

1;
