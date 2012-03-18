package DU::Schema::Result::Drink;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

column description => { data_type => 'ntext' };

column variant_of_drink_id => {
   data_type   => 'int',
   is_nullable => 1,
};

belongs_to variant_of_drink => '::Drink', 'variant_of_drink_id';
has_many names => '::DrinkName', 'drink_id';
has_many links_to_drink_ingredients => '::Drink_Ingredient', 'drink_id';
many_to_many ingredients => 'links_to_drink_ingredients', 'ingredient';

1;

