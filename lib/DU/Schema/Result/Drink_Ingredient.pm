package DU::Schema::Result::Drink_Ingredient;

use DU::Schema::Candy;

column drink_id      => { data_type => 'int' };
column ingredient_id => { data_type => 'int' };

column volume => {
   data_type   => 'float',
   is_nullable => 1,
};

column arbitrary_volume => {
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

1;

