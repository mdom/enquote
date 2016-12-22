#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME       => "Text::Enquote",
    VERSION    => 0.04,
    META_MERGE => {
        "meta-spec" => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url =>
                  'git://github.com/mdom/enquote.git',
                web =>
                  'https://github.com/mdom/enquote',
            },
        },
    },
);

sub MY::c_o {
    "cover:\n\tHARNESS_PERL_SWITCHES=-MDevel::Cover make test && cover";
}
