package DU::Util;

use 5.14.1;
use warnings;

use Sub::Exporter -setup => {
   exports => [qw{
      volume_with_unit drink_as_markdown single_item edit_data
   }],
};
use Lingua::EN::Inflect 'PL';

sub volume_with_unit {
   my $d_i = shift;

   my $v = $d_i->arbitrary_amount;

   return $v if $v;

   return $d_i->amount . ' ' . PL($d_i->unit->name, $d_i->amount) if $d_i->unit;

   return '???'
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
      ( $drink->source ? (
         '', 'Source: ' . $drink->source
      ) : () ),
      "\n",
}

sub single_item {
   my ($action, $name, $arg, $rs) = @_;

   $rs = $rs->cli_find($arg);
   my $count = $rs->count;
   if ($count > 1) {
      say "More than one $name found:";
      my $x = 0;
      print join '', map sprintf("%2d. %s\n", ++$x, $_->view), $rs->all;
      exit 1;
   } elsif ($count == 1) {
      $action->($rs->single)
   } else {
      say "No $name «$arg» found";
      exit 1;
   }
}

sub edit_data {
   my $data = shift;

   require File::Temp;
   require YAML::Syck;

   my ($fh, $fn) = File::Temp::tempfile();
   print {$fh} YAML::Syck::Dump($data);
   close $fh;

   system($ENV{EDITOR} || 'vi', $fn);

   my $yaml = do { local (@ARGV, $/) = $fn; <> };
   YAML::Syck::Load($yaml);
}

1;
