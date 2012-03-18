package DU::Schema::Result::Ingredient;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

column name => {
   data_type => 'nvarchar',
   size      => 50,
};

column description => {
   data_type => 'ntext',
   is_nullable => 1,
};

1;
