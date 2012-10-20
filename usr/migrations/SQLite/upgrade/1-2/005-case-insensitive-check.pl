#!/usr/bin/env perl

use 5.16.0;
use warnings;

use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers
   'dbh';
use Data::Dumper::Concise;

sub check_for_duplicates {
   my ($dbh, $table, $column) = @_;

   my @duplicates = map $_->[0], @{$dbh->selectall_arrayref(<<"SQL")};
   SELECT "$column"
     FROM "$table"
 GROUP BY "$column" COLLATE NOCASE
   HAVING COUNT(*) > 1
SQL
}

dbh(sub {
   my ($dbh, $version_set) = @_;

   my @drink_names = check_for_duplicates($dbh, qw(drink_names name));
   my @ingredient_names = check_for_duplicates($dbh, qw(ingredients name));
   my @unit_names = check_for_duplicates($dbh, qw(units name));
   my @user_names = check_for_duplicates($dbh, qw(users name));

   if (@drink_names) {
      say 'Duplicate drink names found!  This is because you created' .
          ' at least two drinks with the same name but differing case ' .
          '(foo vs Foo.)  Remove the extra one and try again. ';
      say 'Duplicates: ' . Dumper(\@drink_names);
   }

   if (@ingredient_names) {
      say 'Duplicate ingredient names found!  This is because you created' .
          ' at least two ingredients with the same name but differing case ' .
          '(foo vs Foo.)  Remove the extra one and try again. ';
      say 'Duplicates: ' . Dumper(\@ingredient_names);
   }

   if (@unit_names) {
      say 'Duplicate unit names found!  This is because you created' .
          ' at least two units with the same name but differing case ' .
          '(foo vs Foo.)  Remove the extra one and try again. ';
      say '(Honestly how did you even do this?  There is no UI for it!)';
      say 'Duplicates: ' . Dumper(\@unit_names);
   }

   if (@user_names) {
      say 'Duplicate user names found!  This is because you created' .
          ' at least two user with the same name but differing case ' .
          '(foo vs Foo.)  Remove the extra one and try again. ';
      say '(Honestly how did you even do this?  There is no UI for it!)';
      say 'Duplicates: ' . Dumper(\@user_names);
   }

   die 'fix duplicates before running rest of migration!'
      if @drink_names || @ingredient_names || @unit_names || @user_names
});
