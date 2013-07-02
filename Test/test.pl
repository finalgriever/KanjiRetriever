#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use HTML::Parser;
use Data::Dumper;
use HTML::TreeBuilder 3;
use Data::Dumper qw/Dumper/;
use Kanji::Retriever;
use Kanji::Retriever::Dictionary;

main();

sub main {
	my $url = 'http://en.wiktionary.org/wiki/%E4%BA%9C';

	my $retriever = Kanji::Retriever->new($url);

	my $compounds = Kanji::Retriever::Dictionary::getListItems($retriever, "Readings");

	$retriever->delete;

	print Dumper($compounds);
}
