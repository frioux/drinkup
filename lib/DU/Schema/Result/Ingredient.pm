package DU::Schema::Result::Ingredient;

use DU::Schema::Candy
   -components => ['+DBICx::MaterializedPath']
   ;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

column parent => {
   data_type   => 'int',
   is_nullable => 1,
};

column materialized_path => {
   data_type   => 'varchar',
   size        => 255,
   is_nullable => 1,
};

column id => {
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
