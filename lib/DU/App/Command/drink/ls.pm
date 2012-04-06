package DU::App::Command::drink::ls;

use 5.14.1;
use warnings;

use DU::App -command;
use DU::Util 'drink_as_markdown';

sub abstract { 'list drinks' }

sub usage_desc { 'du drink ls' }

sub opt_spec {
   [ 'some_ingredients|s',  'only drinks I can at least partially make' ],
   [ 'no_ingredients|n',  'only drinks I cannot make at all' ],
   [ 'all_ingredients|a',  'only drinks I can make' ],
}

sub execute {
   my ($self, $opt, $args) = @_;


   my $rs = $self->app->app->schema->resultset('Drink');
   my $user = $self->app->app->schema->resultset('User')->search({
      name => 'frew',
   })->single;

   $rs = $rs->some($user) if $opt->some_ingredients;
   $rs = $rs->none($user) if $opt->no_ingredients;
   $rs = $rs->every($user) if $opt->all_ingredients;

   print drink_as_markdown($_) for $rs->all
}

1;

