package DU::Schema::Result::User;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

unique_column name => {
   data_type => 'nvarchar',
   size      => 50,
};

has_many inventory_items => '::InventoryItem', 'user_id';
many_to_many ingredients => 'inventory_items', 'ingredient';

1;
