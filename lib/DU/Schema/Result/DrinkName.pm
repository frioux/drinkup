package DU::Schema::Result::DrinkName;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

column drink_id => { data_type => 'int' };

column name => {
   data_type => 'nvarchar',
   size      => 50,
};

column order => {
   data_type => 'float',
};

unique_constraint [qw(drink_id order)];

belongs_to 'drink', '::Drink', 'drink_id';

1;
