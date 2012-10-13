package DU::Schema::Result::Drink;

use DU::Schema::Candy;

primary_column id => {
   data_type         => 'int',
   is_auto_increment => 1,
};

column description => { data_type => 'ntext' };

column source => {
   data_type   => 'nvarchar',
   size        => 50,
   is_nullable => 1,
};

column variant_of_drink_id => {
   data_type   => 'int',
   is_nullable => 1,
};

belongs_to variant_of_drink => '::Drink', 'variant_of_drink_id', {
   proxy => {
      variant_of_drink_name => 'name',
   },
};
has_many variants => '::Drink', 'variant_of_drink_id';
has_many names => '::DrinkName', 'drink_id';
has_many links_to_drink_ingredients => '::Drink_Ingredient', 'drink_id';
many_to_many ingredients => 'links_to_drink_ingredients', 'ingredient';

sub name {
   shift->names->search(undef, {
      rows => 1,
      order_by => 'order',
   })->get_column('name')->next
}

sub update {
   my ($self, $data) = @_;

   exists $data->{$_} && $self->$_($data->{$_})
      for qw(description source);

   if (my $v = $data->{variant_of_drink}) {
      my $based_on = $self->result_source->schema->resultset('Drink')
         ->find_by_name($v)
            or die 'no such variant';

      $self->variant_of_drink_id($based_on->id);
   }

   $self->next::method;

   $self->names->delete;
   $self->add_to_names({ name => $data->{name}, order => 1 });

   $self->links_to_drink_ingredients->delete;
   for (@{$data->{ingredients}}) {
      my @unit;
      if ($_->{unit}) {
         my $unit_id = $self->result_source->schema->resultset('Unit')
            ->search({ name => $_->{unit} })
            ->get_column('id')
            ->single
            or die "unknown unit $_->{unit} used";
         @unit = ( unit_id => $unit_id )
      }
      $self->links_to_drink_ingredients->create(
         +{
            ( $_->{arbitrary_amount}
               ? ( arbitrary_amount => $_->{arbitrary_amount} )
               : ()
            ),
            ( $_->{unit}
               ? (
                  @unit,
                  amount => $_->{amount},
               )
               : ()
            ),
            ( $_->{notes}  ? ( notes  => $_->{notes}  ) : () ),
            ingredient => { name => $_->{name} },
         }
      );
   }
}

1;

