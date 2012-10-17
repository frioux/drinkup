package DU::App::Command::ingredient::ls;

use 5.16.1;
use Moo;

extends 'DU::App::Command';

sub abstract { 'list ingredients' }

sub usage_desc { 'du ingredient list' }

sub opt_spec {
   [ 'easy_search_by_name|G=s',  'ingredients that match a name, automatically wraps with *s' ],
   [ 'search_by_name|g=s',  'ingredients that match a name (for example *breeze*)' ],
}
sub execute {
   my ($self, $opt, $args) = @_;

   my $rs = $self->rs('Ingredient');

   $rs = $rs->cli_find($opt->search_by_name)
      if $opt->search_by_name;

   $rs = $rs->cli_find('*' . $opt->easy_search_by_name . '*')
      if $opt->easy_search_by_name;

   say '## Ingredients';
   say ' * ' . $_->name for $rs->all
}

1;

