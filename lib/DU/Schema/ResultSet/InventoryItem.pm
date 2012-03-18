package DU::Schema::ResultSet::InventoryItem;

use 5.14.1;
use warnings;

use parent 'DU::Schema::ResultSet';

sub cli_find {
   $_[0]->search({
      "ingredient.name" => { -like => "%$_[1]%" }
   }, {
      join => 'ingredient',
   })
}

1;
