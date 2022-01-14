#!perl
use strict;
use warnings;

use App::PerlNitpick::Rule::ReadableQuotes ();
use Test2::V0 qw( done_testing is );

my @tests = (
    [ '"foo"',             q{'foo'} ],
    [ 'q{}',               'q{}' ],
    [ 'q{ }',              'q{ }' ],
    [ 'q{"}',              'q{"}' ],
    [ 'q{\'}',             'q{\'}' ],
    [ 'q{ \' }',           'q{ \' }' ],
    [ 'q{report\'s name}', 'q{report\'s name}' ],
    [ q{''},               'q{}' ],
    [ q{"\n"},             q{"\n"} ],
    [ q{print "riho";},    q{print 'riho';} ],

    # Multiline strings. String literal newline characetrs.
    [
        q{print "riho
";}, q{print "riho
";}
    ],

);

for my $t (@tests) {
    my ( $code_before, $code_after ) = @$t;

    my $doc   = PPI::Document->new( \$code_before );
    my $o     = App::PerlNitpick::Rule::ReadableQuotes->new();
    my $doc2  = $o->rewrite($doc);
    my $code2 = "$doc2";
    is $code2, $code_after, "$code_before becomes $code_after";
}

done_testing;

