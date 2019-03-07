package Text::Enquote;
use 5.14.0;
use warnings;

use parent 'Exporter';
use utf8;
use charnames ':full';
use Encode qw();

use Mojo::DOM '6.45';
use Mojo::ByteStream 'b';

our @EXPORT_OK = (qw(convert_html convert_text));

my %quotes = (
    q{"} =>
      [ "\N{DOUBLE LOW-9 QUOTATION MARK}", "\N{LEFT DOUBLE QUOTATION MARK}" ],
    q{'} =>
      [ "\N{SINGLE LOW-9 QUOTATION MARK}", "\N{LEFT SINGLE QUOTATION MARK}" ],
);

sub convert_text {
    my $text = shift;
    return $text if $text !~ /\S/;
    my $dom = apply_conversions($text);
    return $dom->all_text;
}

sub convert_html {
    my $text = shift;
    my $dom  = apply_conversions($text);
    return $dom->to_string;
}

sub text_nodes {
    return $_[0]->type eq 'text';
}

sub apply_conversions {
    my $text = shift;
    my $dom  = Mojo::DOM->new($text)->xml(0);
    convert_quotes($dom);
    return $dom;
}

sub convert_quotes {
    my ($dom) = @_;
    my $word_bounding = qr/(?:(?:\A|\s)[[:punct:]]*)/;

    my @nodes = $dom->descendant_nodes->grep(
        sub { $_->type eq 'text' or $_->tag eq 'br' or $_->tag eq 'p' } )
      ->map( sub { $_->type eq 'text' ? $_ : Mojo::DOM->new(' ') } )->each;

    my $text = join( '', map { $_->content } @nodes );

    for ($text) {

        ## 0. Handle special case for "foo ..."
        ## This would be easier if we had perl 5.18 and we could use
        ## ?[[:punct:]-\N{U+2026}]

        s/(\s+(?:(?<!\.)\.\.\.(?!\.)|\N{U+2026})) (["'])
		 /$1 . $quotes{$2}->[1]
		 /gex;

        ## 1. Convert all space quote combinations to open quotes
        s/($word_bounding) (["'])/$1 . $quotes{$2}->[0]/gex;

        ## 2. The remaining quotes must be closed quotes
        s/(["'])/$quotes{$1}->[1]/gex;

        ## 3. Now search for converted single quotes that are actually
        ##    apostrophes

        ## 3.1. Closed quote between word characters
        s/(?<=\w) \N{U+2018} (?=\w)/'/gx;

        ## 3.2. Open quote without a remaining closed quote
        s/($word_bounding)\N{U+201A}(?!.*\N{U+2018})/$1\N{U+27}/g;

        ## 3.3. Open quote with no closed quote until the next open
        ##      quote (single or double)
        s/($word_bounding) \N{U+201A}
	      (?= [^\N{U+2018}]+ (?:\N{U+201A}|\N{U+201C}) )
	     /$1\N{U+27}/gx;

        ## 4. Search for converted closed quotes that are actually apostrophes

        ## 4.1. Closed without open quotes
        s/^([^\N{U+201A}]+?)\N{U+2018}/$1'/g;

        ## 4.2. Closed without open quotes from the last closed
        s/(\N{U+2018}[^\N{U+201A}]+?)\N{U+2018}/$1'/g;
    }

    for my $node (@nodes) {
        my $text = substr( $text, 0, length( $node->content ), '' );
        $node->content( b($text) );
    }
    return;
}

1;

__END__
