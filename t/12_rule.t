BEGIN
{
	use strict;	
	use Test::More 'no_plan';
	# MIDI::Simple uses unquoted strings, but it's yummy.
	$SIG{__WARN__} = sub { return $_[0] unless $_[0] =~ /Unquoted string/ };

	#################
	# test module use
	#################
	use_ok('POE');
	use_ok('POE::Framework::MIDI::Rule');
	use_ok('POE::Framework::MIDI::Bar');
	use_ok('POE::Framework::MIDI::Note');
	use_ok('POE::Framework::MIDI::Rest');
	ok(my $r = POE::Framework::MIDI::Rule->new( context => 'bar' , type => 'foo'));
}


ok(my $testbar = POE::Framework::MIDI::Bar->new( number => 1));
ok(my $testnote = POE::Framework::MIDI::Note->new( name => 'C4', duration => 'qn'));
ok(my $testrest = POE::Framework::MIDI::Rest->new( duration => 'qn' ));
ok($testbar->add_events(($testnote,$testnote,$testnote,$testreste)));
ok(my $testrule = TestRule->new( context => 'bar'));
is($testrule->is_four_four($testbar),1);





package TestRule;
use strict;
use base 'POE::Framework::MIDI::Rule';

# returns a boolean indicating whether a bar is valid 4/4
sub is_four_four {
	my $self = shift;
	my $bar = shift or die "No bar";
	die "$bar is not a Bar Object" unless $bar->isa('POE::Framework::MIDI::Bar');
	my $values = {
		'tsn' => 0.03125,
		'sn' => 0.0625,
		'en' => 0.125,
		'qn' => 0.25,
		'hn' => 0.5,
		'wn' => 1,
	
	};
	
	my $total;
	my @events = $bar->events;
	use Data::Dumper;
	print Dumper(@events);
	
	for(@events) {
		print "Event $_\n";
	}
	
	
	

}


1;



