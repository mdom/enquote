#!/usr/bin/perl

use 5.14.0;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use Test::More;
use Text::Enquote qw(convert_html convert_text);


while (<DATA>) {
    chomp;
    next unless / => /;
    my ( $pre, $post ) = split( ' => ', $_, 2 );
    $pre =~ /^<p/
      ? is( convert_html($pre), $post )
      : is( convert_text($pre), $post )
}

done_testing();

__END__
<p id="BrotO"></p> => <p id="BrotO"></p>
<p> </p> => <p> </p>
<p></p> => <p></p>
<p class="BrotO">foo</p> => <p class="BrotO">foo</p>
<p class="foo">foo</p> => <p class="foo">foo</p>
<p>foo</p> => <p>foo</p>
<p>'</p> => <p>'</p>

<p><br></p> => <p><br></p>
<p><br /></p> => <p><br></p>
<p><br/></p> => <p><br></p>

  =>  
" => „
' => '
"foo" => „foo“
„foo“ => „foo“
'foo' => ‚foo‘
' ' => ' '
'foo' 'bar' => ‚foo‘ ‚bar‘
Das ist "super!" oder ist "super"! => Das ist „super!“ oder ist „super“!
"Ich bin neu!", sagte der Text. Dass ich nur ein ("Beispiel") bin, ist mir egal. "Touché", sagte der andere Text. "Ich bin alt!". => „Ich bin neu!“, sagte der Text. Dass ich nur ein („Beispiel“) bin, ist mir egal. „Touché“, sagte der andere Text. „Ich bin alt!“.
"test" ["ui ui"] => „test“ [„ui ui“]
("so wie jeder andere auch") => („so wie jeder andere auch“)
"(so wie jeder andere auch)" => „(so wie jeder andere auch)“
"(test test)" "[test test]" => „(test test)“ „[test test]“
"test" ["ui ui"] => „test“ [„ui ui“]
"test" "[ui ui]" => „test“ „[ui ui]“

Ich "bin 'nur" ein Blindtest' => Ich „bin 'nur“ ein Blindtest'
Ich „bin 'nur“ ein Blindtest' => Ich „bin 'nur“ ein Blindtest'
'ne Mark => 'ne Mark
So 'n Mist, ich brauch 'ne Mark => So 'n Mist, ich brauch 'ne Mark
So 'n Mist, ich brauch eine 'Mark' => So 'n Mist, ich brauch eine ‚Mark‘
die Grimm'schen Märchen => die Grimm'schen Märchen
die Grimmschen Mä'rchen => die Grimmschen Mä'rchen
<p>die <i>Grimm</i>'schen Märchen</p> => <p>die <i>Grimm</i>'schen Märchen</p>

Andrea's Blumenecke => Andrea's Blumenecke
Hans Sachs' Gedichte => Hans Sachs' Gedichte
'Ich will nicht', sagte er den Leut' => ‚Ich will nicht‘, sagte er den Leut'
‚Ich will nicht‘, sagte er den Leut' => ‚Ich will nicht‘, sagte er den Leut'

Lass doch dieses ewige "Ich will nicht!"! => Lass doch dieses ewige „Ich will nicht!“!

<p><a>"wirkliche Leben"</a></p> => <p><a>„wirkliche Leben“</a></p>
<p>"<a>wirkliche Leben</a>"</p> => <p>„<a>wirkliche Leben</a>“</p>
<p>"<em>Hello</em>"<br>"<em>World</em>"<br></p> => <p>„<em>Hello</em>“<br>„<em>World</em>“<br></p>
<p>"foo"</p><p>"bar"</p> => <p>„foo“</p><p>„bar“</p>

"quux…" => „quux…“
<p>"foo …"</p> = <p>„foo …“</p>
"quux …" => „quux …“
