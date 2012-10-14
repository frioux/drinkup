package DU::RecipeParser;

use 5.16.1;
use warnings;

use DU;
use Pegex;
use Sub::Exporter::Progressive -setup => {
  exports => [qw( decode_recipe encode_recipe )],
  groups => {
    default => [qw( decode_recipe encode_recipe )],
  },
};
use Lingua::EN::Inflect 'PL';
use File::Share ':all';
use IO::All;

my $grammar = io->file(dist_file('DU', 'drinkup.pgx'))->all;

sub decode_recipe {
   pegex($grammar, {receiver => 'DU::RecipeParser::Data'})->parse($_[0]);
}

sub encode_recipe {
   my $ingredients;

   for my $i (@{$_[0]->{ingredients}}) {
      $ingredients .= " * $i->{amount} " . PL($i->{unit}, $i->{amount})
         . " of $i->{name}\n";
      $ingredients .= " # $i->{note}\n" if $i->{note};
   }

   my $source = '';
   $source = "Source: $_[0]->{source}" if $_[0]->{source};

<<"RECIPE";
$_[0]->{name}

$_[0]->{description}

$ingredients
$source
RECIPE
}

package DU::RecipeParser::Data;
use base 'Pegex::Receiver';

my $data;

sub initial {
    $data = {};
}

sub got_unit { $_[1]->[0] }

sub got_cocktail {
    $data->{name} = $_[1];
}

sub got_ounce { 'ounce' }
sub got_tablespoon { 'tablespoon' }
sub got_teaspoon { 'teaspoon' }
sub got_dash { 'dash' }

sub got_description {
    $data->{description} = $_[1];
}

sub got_instructions {
    $data->{instructions} = $_[1];
}

sub got_ingredients {
    $data->{ingredients} = [
        map +{
           amount => 0 + $_->[0],
           unit => $_->[1],
           name => $_->[2],
           ($_->[3] ? (note => $_->[3]) : ()),
        }, @{$_[1]}
    ];
}

sub got_metadata {
    $data->{lc $_[1]->[0]} = $_[1]->[1]
}

sub final {
    return $data;
}

1;
