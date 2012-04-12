package DU::Schema::Result::Ingredient;

use DU::Schema::Candy -components => [
   'Helper::Row::OnColumnChange'
];

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

belongs_to direct_kind_of => '::Ingredient', 'kind_of_id', { join_type => 'left' };
has_many direct_kinds => '::Ingredient', 'kind_of_id';
has_many inventory_items => '::InventoryItem', 'ingredient_id';
has_many links_to_drink_ingredients => '::Drink_Ingredient', 'ingredient_id';

sub _set_materialized_path {
   my $self = shift;

   if ($self->kind_of_id) {
      $self->discard_changes;

      $self->_materialized_path(
         $self->direct_kind_of->_materialized_path . q(/) . $self->id
      );
   } else {
      $self->_materialized_path($self->id)
   }
   $self->update
}

sub _fix_for_updates {
   my ( $self, $old, $new ) = @_;

   $self->_set_materialized_path;

   $_->_fix_for_updates for $self->direct_kinds->all
}

sub insert {
   my $self = shift;

   my $ret = $self->next::method;

   $ret->_set_materialized_path;

   return $ret;
}

after_column_change kind_of_id => {
   txn_wrap => 1,
   method => '_fix_for_updates',
} for qw(kind_of_id materialized_path);

has_many
   kind_of => '::Ingredient',
   sub {
      my $args = shift;

      my $path_separator = q(/);
      my $rest = "$path_separator%";

      my $me = {
         "$args->{self_alias}.id" => { -ident => "$args->{foreign_alias}.id" }
      };
      return ([{
            "$args->{self_alias}.materialized_path" => {
               -like => \["$args->{foreign_alias}.materialized_path" . ' || ' . '?',
                  [ {} => $rest ]
               ],
            }
         },
         $me
      ],
      $args->{self_rowobj} && {
         "$args->{foreign_alias}.id" => {
            -in => [ split qr(/), $args->{self_rowobj}->_materialized_path ]
         },
      });
   };

has_many
   kinds => '::Ingredient',
   sub {
      my $args = shift;

      my $path_separator = q(/);
      my $rest = "$path_separator%";

      my $me = {
         "$args->{self_alias}.id" => { -ident => "$args->{foreign_alias}.id" }
      };
      return [{
         "$args->{foreign_alias}.materialized_path" => {
            -like => \["$args->{self_alias}.materialized_path" . ' || ' . '?',
               [ {} => $rest ]
            ],
         }
      }, $me ]
   };

1;
