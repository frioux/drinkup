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

unique_column name => {
   data_type => 'nvarchar',
   size      => 50,
};

column description => {
   data_type => 'ntext',
   is_nullable => 1,
};

belongs_to kind_of => '::Ingredient', 'kind_of_id', { join_type => 'left' };
has_many inventory_items => '::InventoryItem', 'ingredient_id';
has_many links_to_drink_ingredients => '::Drink_Ingredient', 'ingredient_id';

belongs_to
   kind_of => '::Ingredient',
   sub {
      my $args = shift;

      my $path_separator = q(/);
      my $rest = "$path_separator%";

      return ({
         "$args->{self_alias}.materialized_path" => {
            -like => {
               -concat => [
                  { -ident => "$args->{foreign_alias}.materialized_path" },
                  $rest
               ]
            }
         }
      },
      $args->{self_rowobj} && {
         "$args->{foreign_alias}.id" => {
            -in => split qr(/), $args->{self_rowobj}->materialized_path
         }
      });
   };

1;
