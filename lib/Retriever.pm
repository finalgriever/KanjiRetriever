#!/usr/bin/perl -w
package Kanji::Retriever;

use strict;
use LWP::UserAgent;
use HTML::Parser;
use Encode qw(decode encode);
use Data::Dumper qw/Dumper/;
use HTTP::Response;
use utf8;

sub new {
	my ($class, $url) = @_;
	my $doc;
	my $self;

	if($url)
	{
		$self = changeDoc($self, $url);
	}

	bless $self, $class;
	return $self;
}

sub changeDoc {
	my ($self, $url) = @_;
	my $htmlString;

	$self->{url} = $url;

	if($self->{doc}) {
		$self->{doc}->delete();
	}
	my $ua = LWP::UserAgent->new();
	$htmlString = $ua->get($self->{url});
	$htmlString = decode('UTF-8', $htmlString->content);
	
	die "Could not open website: $url" unless $htmlString;
	$self->{doc} = HTML::TreeBuilder->new_from_content($htmlString);

	return $self;
}

sub delete {
	my $self = shift;

	if($self->{doc}) {
		$self->{doc}->delete();
	}
}

1;
