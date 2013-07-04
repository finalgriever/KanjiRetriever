#!/usr/bin/perl -w
package Retriever::Dictionary;

use strict;
use LWP::Simple;
use HTML::Parser;
use Data::Dumper;
use HTML::TreeBuilder 3;

use base qw/Retriever/;

use constant TABLE_CLASS => 'sortable wikitable jquery-tablesorter';

sub getDictionary {
	my $self = shift;

	my $dictionary;
	my $table = $self->{doc}->find_by_attribute("class", TABLE_CLASS);
	my @rows = $table->find_by_tag_name("tbody")->find_by_tag_name("tr");;

	return $self->processRows(@rows);
}

sub processRows {
	my $self = shift;
	my @rows = @_;
	my $dictionary;
	my $count = 0;
	my $logger = get_logger();

	foreach(@rows) {
		my @tds = $_->find_by_tag_name("td");
		my $key = $tds[0]->as_text();
		eval {
			if (!$key) {
				die "Failed to load unknown kanji";
			}
			$dictionary->[$key] = {};
	
			$dictionary->[$key]->{character} = getCharacter(   $tds[1]) or die "Could not retrieve kanji: $key\n";
			$dictionary->[$key]->{meaning}   = getMeaning(     $tds[7]) or die "Could not retrieve meaning: $key\n";
			$dictionary->[$key]->{readings}  = getReadings(    $tds[1]) or die "Could not retrieve readings: $key\n";
			$dictionary->[$key]->{compounds} = getCompounds(   $tds[1]) or $logger->warn("Could not retrieve compounds for: $key");
			$dictionary->[$key]->{strokes}   = getNumStrokes(  $tds[4]) or $logger->warn("Could not retrieve stroke count for :$key");
			$dictionary->[$key]->{grade}     = getGrade(       $tds[5]) or $logger->warn("Could not retrieve grade for: $key");
		};
		if ($@) {
			delete $dictionary->[$key];
			$logger->error("Failed dictionary entry, $key: $@");
		}
		$logger->info("Dictionary entry successful for Kanji: $key");
	}

	if($dictionary)
	{
		return ($dictionary);
	}
	else {
		die "Unknown error occurred while building the dictionary";
	}
}

sub getCharacters {
	my $td = shift;
	my $character = $td->find_by_tag_name("a")->as_text();

	return $character;
}

sub getNumStrokes {
	my $td = shift;

	my $numStrokes = $td->as_text();

	return $numStrokes;
}

sub getGrade {
	my $td = shift;

	my $numGrade = $td->as_text();
}

sub getMeaning {
	my $td = shift;

	my $meaning = $td->as_text();
}

sub getReadings {
	my $td = shift;

	my $anchor = $td->find_by_tag_name("a");
	my $retriever = Retriever::new($anchor->attr("href"));

	my $readings = getListItems($retriever, "Readings");

	$retriever->delete;

	return $readings;
}

sub getCompounds {
	my $td = shift;

	my $anchor = $td->find_by_tag_name("a");
	my $retriever = Retriever::new($anchor->attr("href"));

	my $compounds = getListItems($retriever, "Compounds");

	$retriever->delete;

	return $compounds;
}

sub getListItems {
	my ($retriever, $heading) = @_;
	my $flag = 0;

	# Get all the elements in the containing div, because it's the closest approximation to a colleciton we have
	
	my $div = $retriever->{doc}->find_by_attribute("id", "mw-content-text");
	my @elements = $div->content_list;
	
	foreach (@elements) {
		if($flag) {                                     # If the right heading was found in the last element
			my @listItems = $_->find_by_tag_name("li"); # Get all the list items
			my @textList;
			foreach my $item(@listItems) {              # And turn them all into text
				push (@textList, $item->as_text());
			}
			return \@textList;
		}
		else {
			if($_->look_down(id => $heading)) {         # If you find the right heading, let the algo
				$flag = 1;                              # know that the next element will have li's it wants
			}
		}
	}

	return;
}

1;
