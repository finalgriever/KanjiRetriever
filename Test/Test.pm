#!/usr/bin/perl -w
package Kanji::Retriever::Test;

use strict;
use LWP::Simple;
use HTML::Parser;
use Data::Dumper;
use HTML::TreeBuilder 3;

use base qw/Kanji::Retriever/;

sub getSpecific {
	my $self = shift;

	my $tree = HTML::TreeBuilder->new_from_content($self->{doc});

	my $heading = $tree->find_by_tag_name('h3');
	print $heading->as_text() . "\n";

	$tree->delete();
}	

1;
