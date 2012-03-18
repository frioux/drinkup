package DU::Schema::Result::InventoryItem;

use DU::Schema::Candy;

column ingredient_id => { data_type => 'int' };
column user_id => { data_type => 'int' };

primary_key 'ingredient_id', 'user_id';

belongs_to user => '::User', 'user_id';
belongs_to ingredient => '::Ingredient', 'ingredient_id';

1;
