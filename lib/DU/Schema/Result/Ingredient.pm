package DU::Schema::Result::Ingredient;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

unique_column name => {
   data_type => 'nvarchar',
   size      => 50,
};

column description => {
   data_type => 'ntext',
   is_nullable => 1,
};

has_many inventory_items => '::InventoryItem', 'ingredient_id';
has_many links_to_drink_ingredients => '::Drink_Ingredient', 'ingredient_id';

1;
