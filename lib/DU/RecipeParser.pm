package DU::RecipeParser;

use 5.16.1;
use warnings;

use Pegex;

my $grammar = <<'PEGEX';
%grammar drinkup
%version 0.0.1

recipe:
    cocktail
    description
    ingredients
    instructions?
    footers

cocktail: /
    (: ~ <EOL> )?   # Leading whitespace?
    (<NS> <ANY>*?)  # Cocktail name. Capture it.
    ~ <EOL>         # Trailing whitespace
/

description: /
    (<ALL>*?)       # Description text
    (= <EOL> <BLANK>* <STAR> ) # Not the ingredients
    ~               # Remaining whitespace
/

# Ingredient parts
ingredients: ingredient+

ingredient:
    / <SPACE>* <STAR> <SPACE>* /
    number
    / <SPACE>* /
    unit
    / <SPACE>* /
    name
    / <SPACE>* <EOL> /
    note?

# probably need to attempt to parse 1 1/2 or 1 + 1/2
# cribbed from json-pgx, minus the exponent version because if you use that
# in a recipe you should change your units!
number: /(
   (: 0 | [1-9] <DIGIT>* )?
   (: <DOT> <DIGIT>+ )?
   (: ~ <PLUS>? ~ <DIGIT>+ ~ <SLASH> ~ <DIGIT>+ )?
)/

# this will probably need a hardcoded list at some point :(
# BLKB: Or maybe use a validator?  depends on the size of the list
unit:   /(<WORD>+)(: ~ of)?/

name:   / (<ANY>+?) ~ (= <EOL>) /

note:   / <HASH> <SPACE>* (<ANY>+?) <SPACE>* <EOL> /

instructions: /
   (<ALL>*?)         # instruction text
   (= <EOL> <footer_name> <COLON> ) # Not the footers
   ~
/

footers: metadata+

metadata: / (<footer_name>) <COLON> <SPACE>* (<ANY>+?) ~ <EOL> /

footer_name: / [<WORDS>-]+ /
PEGEX

sub parse {
   pegex($grammar, {receiver => 'DU::RecipeParser::Data'})->parse($_[1]);
}

package DU::RecipeParser::Data;
use base 'Pegex::Receiver';

my $data;

sub initial {
    $data = {};
}

sub got_cocktail {
    $data->{name} = $_[1];
}

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
           ingredient => $_->[2],
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
