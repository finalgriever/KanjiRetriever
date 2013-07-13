#!/usr/bin/perl

use Retriever::Stroke;
use Retriever::Dictionary;
use Log::Log4perl qw/get_logger/;
use SQL;		# Need to check on this
Log::Log4perl->init("log.conf");

use constant WIKTIONARY => 'http://en.wikipedia.org/wiki/List_of_j%C5%8Dy%C5%8D_kanji';
use constant JISHO      => 'http://jisho.org/kanji/details/';

main();

sub main {
	my $dictionaryRetriever = Retriever::Dictionary->new(WIKTIONARY);
	my $logger = get_logger;

	eval {
		my $dictioanary = $dictionaryRetriever->getDictionary();
		$dictionaryRetriever->delete();
	}
	if ($@) {
		$logger->error("The dictionary did not compile properly: $@");
		die;
	}

	retrieveStrokeImages($dictionary);

	# Start building your dang database
}

sub retrieveStrokeImages {
	my $dictionary = shift;

	foreach my $entry (@{$dictionary}) {
		my $kanji = $entry->{character};
		my $url = JISHO . $kanji;
		my $strokeRetriever = Retriever::Stroke->new($url);
		my $strokeImage;
		eval {
			$strokeImage = $strokeRetriever->getStrokeImage();
		}
		if($@) {
			$logger->error("Failed to retrieve image for $kanji: $@");
			$strokeRetriever->delete();
		}
		$entry->{strokeImage} = $strokeImage;
		$strokeRetriever->delete();
	}
}
