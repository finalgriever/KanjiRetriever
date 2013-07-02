#!/usr/bin/perl
use strict;
use Kanji::Retriever::Stroke;
use Data::Dumper qw/Dumper/;

my $test = Kanji::Retriever::Stroke->new("http://jisho.org/kanji/details/%E9%9B%A8");

$test->getStrokeImage();

