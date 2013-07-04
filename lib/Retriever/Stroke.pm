#!/usr/bin/perl -w
package Retriever::Stroke;

use strict;
use LWP::Simple;
use HTML::Parser;
use Data::Dumper;
use HTML::TreeBuilder 3;
use Image::Grab qw/grab/;

use base qw/Retriever/;
use constant DIV_NAME => "stroke_diagram";

sub getStrokeImage {
	my $self = shift;

	my $imageFileName = $self->getFileName();
	my $image = grab(URL => $imageFileName) or die "Failed to grab image from $imageFileName\n";

	return $image;
}	

sub getFileName {
	my $self = shift;

	my $div = $self->{doc}->find_by_attribute("class", DIV_NAME);
	my $img = $div->look_down(_tag => 'img');

	my $fileName = 'http://www.jisho.org' . $img->attr("src");

	return $fileName;
}

1;
