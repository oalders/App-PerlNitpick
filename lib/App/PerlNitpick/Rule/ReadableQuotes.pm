package App::PerlNitpick::Rule::ReadableQuotes;

# ABSTRACT: Re-quote strings with single quotes ('' or q{}) if they look "simple"

=encoding UTF-8

=head1 DESCRIPTION

This nitpicking rule re-quotes simple strings with single-quote. For example,
C<"coffee"> becomes C<'coffee'> and C<"isn't"> becomes C<q{isn't}>.

=head2 Simple strings ?

Simple strings is a subset of strings that satisfies all of these
constraints:

    - is a string literal (not variable)
    - is quoted with: q, qq, double-quote ("), or single-quote (')
    - is a single-line string
    - has no interpolations inside
    - has no quote characters inside
    - has no sigil characters inside
    - has no metachar

For example, here's a short list of simple strings:

    - q<肆拾貳>
    - qq{Latte Art}
    - "Spring"
    - "Error: insufficient vespene gas"

While here are some counter examples:

    - "john.smith@example.com"
    - "'s-Gravenhage"
    - 'Look at this @{[ longmess() ]}'
    - q<The symbol $ is also known as dollor sign.>

Roughly speaking, given a string, if you can re-quote it with single-quote (')
without changing its value -- then it is a simple string.

=cut

use Moose;

use PPI::Document ();

sub rewrite {
    my ( $self, $doc ) = @_;

    my @todo;

    push @todo,
        @{
        $doc->find(
            sub {
                (
                           $_[1]->isa('PPI::Token::Quote::Literal')
                        || $_[1]->isa('PPI::Token::Quote::Single')
                        || ( $_[1]->isa('PPI::Token::Quote::Double')
                        && !$_[1]->interpolations )
                );
            }
            )
            || []
        };

    for my $tok (
        @{
            $doc->find(
                sub { $_[1]->isa('PPI::Token::Quote::Interpolate') }
                )
                || []
        }
    ) {
        my $value = $tok->string;
        next if $value =~ /[\\\$@%\'\"]/ || index( $value, "\n" ) > 0;
        push @todo, $tok;
    }

    for my $tok (@todo) {

        # I probably know what I am doing.
        my $value = $tok->string;
        next if $value =~ m{\\n} || $value =~ m{\n};
        if ( $value =~ m{["']} ) {
            $tok->{content} = sprintf( 'q{%s}', $tok->string );
        }
        elsif ( $value =~ m{\A\s+\z} || $value eq q{} ) {
            $tok->{content} = sprintf( 'q{%s}', $tok->string );
        }
        else {
            $tok->{content} = sprintf( q{'%s'}, $tok->string );
        }
        bless $tok, 'PPI::Token::Quote::Single';
    }

    return $doc;
}

1;
