#!perl

use 5.16.0;
use warnings;

use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers 'schema_from_schema_loader';

schema_from_schema_loader({
   naming => 'v7',
   constraint => qr<^(?:units|users)$>i },
sub {
   my ($schema, $version_set) = @_;

   $schema->resultset('Unit')->populate([
      [qw(name gills)],
      [ounce      => 1 / 4         ] ,
      [tablespoon => 1 / 4 / 2     ] ,
      [teaspoon   => 1 / 4 / 2 / 3 ] ,
      [dash       => undef         ] ,
   ]);

   $schema->resultset('User')->create({ name => 'frew' });
});

