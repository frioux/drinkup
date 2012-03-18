package DU::Util;

use 5.14.1;
use warnings;

use Lingua::EN::Inflect 'PL';

my %units_per_gill = (
   4 => 'shot',
   8 => 'tablespoon',
   24 => 'teaspoon',
);

sub volume_with_unit {
   my $d_i = shift;

   my $v = $d_i->arbitrary_volume;

   return $v if $v;

   my $volume = $d_i->volume;

   for (sort { $a <=> $b } keys %units_per_gill) {
      my $conv = $volume * $_;
      return $conv . ' ' . PL($units_per_gill{$_}, $conv)
         if abs($conv - int $conv) < 0.0001;
   }
}

sub drink_as_markdown {
   my $drink = shift;

   return join "\n", '## ' . $drink->name,
      '',
      '## Ingredients',
      '',
      (map ' * ' . volume_with_unit($_) . ' of ' . $_->ingredient->name,
         $drink->links_to_drink_ingredients->all
      ),
      '',
      '## Description',
      '',
      $drink->description,
      ( $drink->variant_of_drink ? (
         '', 'Variant of ' . $drink->variant_of_drink->name,
      ) : () ),
      ( $drink->variants->count ? (
         '', 'Variants: ' . join ', ', map $_->name, $drink->variants->all,
      ) : () ),
      "\n",
}

1;
