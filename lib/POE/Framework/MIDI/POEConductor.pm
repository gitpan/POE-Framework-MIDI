# $Id: POEConductor.pm,v 1.1.1.1 2004/11/22 17:52:11 root Exp $

package POE::Framework::MIDI::POEConductor;
use strict;
use vars '$VERSION'; $VERSION = '0.02';
use POE::Framework::MIDI::Conductor;
use base 'POE::Framework::MIDI::Conductor'; 
use POE;
use MIDI::Simple;

# session builder - ala dngor
sub spawn {
    my $class = shift;
    my $self = $class->new(@_);
    POE::Session->new( 
    $self => [qw(_start _stop start_musicians made_bar musician_query) ]);
    return undef;
}

sub _start {
    my ($self, $kernel, $session, $heap) = @_[OBJECT, KERNEL, SESSION, HEAP];
    $kernel->post($session,'start_musicians');
}

sub _stop {
    my ($self, $kernel, $session, $heap) = @_[OBJECT, KERNEL, SESSION, HEAP];
    print "rendering...\n" if $self->{cfg}->{verbose};
    $self->render('test.mid');    
    print "conductor is all done.  take a bow.\n" if $self->{cfg}->{verbose};    
}

sub start_musicians {
    my ($self, $kernel, $session, $heap) = @_[OBJECT, KERNEL, SESSION, HEAP];
    my $musicians = $self->{cfg}->{musicians} or die "no musicians defined in config";

    for (@$musicians) 
    { 
    	POE::Framework::MIDI::POEMusician->spawn($_)
    }
    my $musician_names = $self->musician_names;
    for my $barnum (1..$self->{cfg}->{bars}) {
        for (@$musician_names) { $kernel->post($_, 'make_a_bar' => $barnum) }
    } 
}

# grabs bars from musicians as they're created
sub made_bar {
    my ($self, $kernel, $session, $heap, $barnum, $bar, $musician_object) 
        = @_[OBJECT, KERNEL, SESSION, HEAP, ARG0, ARG1, ARG2 ];

    $self->add_bar({
        musician_name => $musician_object->name,
        channel => $musician_object->channel,
        bar => $bar,
        barnum => $barnum
    });
}

sub musician_query {
    my ($self, $kernel, $session, $heap, $querystring) =
        @_[OBJECT, KERNEL, SESSION, HEAP,ARG0];
    die "null querystring passed from musician $session->{name}" unless $querystring;
    print "query with $querystring\n";    
}

1;

__END__

=head1 NAME

POE::Framework::MIDI::POEConductor - Management and rendering of 
POEMusician objects

=head1 ABSTRACT

=head1 DESCRIPTION

POE functionality for the management of POEMusician objects, and 
eventual rendering down to perl code for MIDI::Simple via the 
Conductor's 'render' method. 

=head1 SYNOPSIS

  use POE::Framework::MIDI::POEMusician; 

  #... include your musician objects here ...

  POE::Framework::MIDI::POEConductor->spawn({
      bars => 30,
      verbose => 1,
      debug => 1,
      filename => 'test_output.mid',
      musicians => [
          {
              name => 'frank',

              # specify which module you want to have "play" this track. 
              # 
              # the only real requirement for a musician object is
              # that it define a 'make_bar' method.  ideally that should
              # return POE::Framework::MIDI::Bar( { number => $barnum } );
              # or a ::Phrase( { number => $barnum } );

              # set the package you want to generate events on this channel
              package => 'POE::Framework::MIDI::Musician::Your::Musicians::GuitarFreak',

              # which channel should these events end up on?    
              channel => 1,

              # which patch should we use?  frank likes the jazz guitar sound.
              patch => '27',
          },

          {
              name => 'ike',
              package => 'POE::Framework::MIDI::Musician::Your::Musicians::MyOrganPlayer',
              channel => 2,
              patch => '60',
          },
          {
              name => 'terry',
              package => 'POE::Framework::MIDI::Musician::Your::Musicians::MyFunkyDrummer',
              channel => 9, # drum channel - zero based
              patch => '58',
          },
      ],
  }); 

  $poe_kernel->run;

=head1 SEE ALSO

L<POE>

L<MIDI::Simple>

L<POE::Framework::MIDI::Conductor>

L<http://justsomeguy.com/code/POE/POE-Framework-MIDI>

=head1 AUTHOR

Primary: Steve McNabb E<lt>steve@justsomeguy.comE<gt>

CPAN ID: SMCNABB

Secondary: Gene Boggs E<lt>cpan@ology.netE<gt>

CPAN ID: GENE

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2002 Steve McNabb. All rights reserved.
This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file 
included with this module.

=cut
