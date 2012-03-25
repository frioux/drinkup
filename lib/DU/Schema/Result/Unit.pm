package DU::Schema::Result::Unit;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

unique_column name => {
   data_type => 'nvarchar',
   size      => 50,
};

# null means unitless
column gills => {
   data_type => 'float',
   is_nullable => 1,
};

1;
