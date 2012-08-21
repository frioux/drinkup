package DU::Schema::Result::Ingredient;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

column kind_of_id => {
   data_type         => 'int',
   is_auto_increment => 1,
   is_nullable       => 1,
};

column materialized_path => {
   data_type   => 'varchar',
   is_nullable => 1,
   size        => 255,
   accessor    => '_materialized_path',
};

unique_column name => {
   data_type => 'nvarchar',
   size      => 50,
};

column description => {
   data_type => 'ntext',
   is_nullable => 1,
};

__PACKAGE__->load_components('MaterializedPath');

sub materialized_path_columns {
   return {
      kind_of => {
         parent_column                => 'kind_of_id',
         parent_fk_column             => 'id',
         materialized_path_column     => 'materialized_path',
         parent_relationship          => 'direct_kind_of',
         children_relationship        => 'direct_kinds',
         full_path                    => 'kind_of',
         reverse_full_path            => 'kinds',
         include_self_in_path         => 1,
         include_self_in_reverse_path => 1,
      },
   }
}


belongs_to direct_kind_of => '::Ingredient', 'kind_of_id', {
   join_type => 'left',
   proxy => {
      direct_kind_of_name => 'name',
   },
};
has_many direct_kinds => '::Ingredient', 'kind_of_id';
has_many inventory_items => '::InventoryItem', 'ingredient_id';
has_many links_to_drink_ingredients => '::Drink_Ingredient', 'ingredient_id';

1;
