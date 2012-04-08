package DU::Schema::Result::Drink_Ingredient;

use DU::Schema::Candy;

primary_column drink_id      => { data_type => 'int' };
primary_column ingredient_id => { data_type => 'int' };

column unit_id => {
   data_type => 'int',
   is_nullable => 1,
};

column amount => {
   data_type   => 'float',
   is_nullable => 1,
};

column arbitrary_amount => {
   data_type   => 'nvarchar',
   size        => 50,
   is_nullable => 1,
};

column notes => {
   data_type   => 'ntext',
   is_nullable => 1,
};

belongs_to drink      => '::Drink', 'drink_id';
belongs_to ingredient => '::Ingredient', 'ingredient_id';
belongs_to unit => '::Unit', 'unit_id';

1;

