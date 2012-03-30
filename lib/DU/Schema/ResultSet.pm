package DU::Schema::ResultSet;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::IgnoreWantarray
   Helper::ResultSet::SetOperations
   Helper::ResultSet::ResultClassDWIM
   Helper::ResultSet::Me
));

sub _glob_to_like {
   my ($self, $kinda_like) = @_;

   my $like = $kinda_like;

   $like =~ s/\*/%/g;
   $like =~ s/\?/_/g;

   return { -like => $like }
}

1;
