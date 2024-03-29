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
	use_ok('POE::Framework::MIDI::Note');
	ok(my $note = POE::Framework::MIDI::Note->new( name => 'C2', duration => 'en'));
	is($note->duration,'en');
	is($note->name,'C2');	
}