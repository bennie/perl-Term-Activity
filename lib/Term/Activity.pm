=head1 NAME:

Term::Activity - Process Activity Display Module

=head1 SYNOPSIS:

This module is designed to produce informational STDERR output while a 
process is funinctioning over many iterations or outputs. It is instanced 
with an optional name and other configurable values and is then called on 
each iterative loop.

=head1 DESCRIPTION:

The information displayed is the current time processed (measured since 
the instancing of the module), the number of actions second, a text-graphic 
indicator of activity (skinnable), and the total count of actions thus far.

An example output (on a small terminal) might appear like this:

  03:13:54 1 : [~~~~~~~~~~~~~~~~~\_______________] 9,461

Showing that nearly three hours and 14 minues have occured with a 
current rate of 1 action per second, for a total of 9,461 total actions.
(For the curious, the skin shown is the default skin, AKA 'wave')

The display occurs on a single line that is updated regularly. The 
display automatically calibrates itself so that it appears to update 
approximately once a second.

When the Term::Activity module passes out of scope it updates the display 
with the final time, count, and a newline before exiting.

Term::Activity can resize itself to the width of the current window if
Term::Size is installed. If not, it defaults to an 80-character display.
Term::Size is thouroughly reccomended.

=head1 USAGE:

=head2 Basic Usage:

  my $ta = new Term::Activity;

  while ( doing stuff ) {
    $ta->tick;
  }

=head2 Process labels:

You can label the output with a string to be displayed along with the 
other output. This is handy for scripts that go through multiple 
processess.

You can either instance them as a scalar value:

  my $ta = new Term::Activity 'Batch7';

Or via a configuration hash reference:

  my $ta = new Term::Activity ({ label => 'Batch7' });

=head2 Skins:

Skins can be selected via a configuration hash reference. Currently there 
are two skins 'wave' and 'flat.' "Wave" is the default skin.

  my $ta = new Term::Activity ({ skin => 'flat' });

The "flat" skin cycles through a series of characters. You may also 
provide an arrayreference of your favorite characters if you'd like 
different ones:

  my $ta = new Term::Activity ({ 
     skin  => 'flat',
     chars => [ '-', '=', '%', '=', '-' ]
  });


=head2 Multiple Instances:

As stated above, when the Term::Activity module passes out of scope it 
updates the display with the final time, count, and a newline before exiting.
Consuquently if you would like to use Term::Activity multiple times in a 
single program you will need to undefine the object and reinstance it:

  my $ta = new Term::Activity;

  while ( doing stuff ) {
    $ta->tick;
  }

  $ta = undef;
  $ta = new Term::Activity;

  while ( doing more stuff ) {
    $ta->tick;
  }

  (lather. rinse. repeat.)

=head1 KNOWN ISSUES:

Resizing the window during execution may cause the status bar to stop
refreshing properly.

Is the window is too small to accomodate the time, label, count, and 
basic spacing (that is, there is less that 0 spaces for the activity to 
be displayed) the effect, while being preety in a watching-the-car-wreck 
way, it is not informative. Remember to keep your label strings short.

=head1 AUTHORSHIP:

  Phillip Pollard <phil@crescendo.net>
  Kristina Davis <krd@menagerie.tf>

  Derived from Util::Status 1.12 2003/09/08 18:05:26
  With permission granted from Health Market Science, Inc.

=head1 SEE ALSO:

  Term::ProgressBar

=cut

#*************************************************************************

package Term::Activity;

use 5.006;
use strict;
use warnings;

our $VERSION = '1.00';

eval {
  require Term::Size;
};

if ($@) {
  our $width = 80;
  our $term = 0;
} else {
  import Term::Size;
  our $width = Term::Size::chars(*STDOUT{IO});
  our $term = 1;
}

sub new {
  my     $self = {};
  bless  $self;

  our $marker   = 0;
  our $skip     = our $width - 19;

  our $ants     = [ map { ' '; } ( 1 .. $skip ) ];

  if ( UNIVERSAL::isa($_[1],'HASH') ) {
    our $name   = $_[1]->{label} || '';
    our $nl     = length $name;
    my $skin	= $_[1]->{skin} || 'wave';
    my $c       = $_[1]->{chars};

    no warnings;

    if ($skin eq 'flat') {
      $self->_ants_basic_init($c);
      *_ants = \&_ants_basic;
    } else {
      $self->_ants_wave_init($c);
      *_ants = \&_ants_wave;
    }

  } else {
    our $name   = $_[1] || "";
    our $nl     = length $name;
    $self->_ants_wave_init;
    *_ants = \&_ants_wave;
  }

  our $count    = 0;
  our $interval = 100;

  our $start    = time;
  our $last     = $start;   

  our $name     =~ s/[\r\n]//g;

  return $self;
}

sub DESTROY {
  my $self = shift @_;
  if ( our $count > 0 ) {
    $self->_update;
    print STDERR "\n";
  }
}

sub tick {
  my $self = shift @_;
  our $count++;
  print STDERR "\n" if $count == 1;
  return 0 if $count % our $interval;
  return $self->_update;
}

sub _ants_basic_init {
  my $self = shift @_;
  my $char = shift @_;
  if ( ref $char && scalar(@$char) > 1 ) {
    our $chars = $char;
  } else {
    our $chars = [ '.', '=', '~', '#', '^', '-' ];
  }
}

sub _ants_basic {
  no warnings 'uninitialized';

  our ( $ants, $chars, $marker, $skip );
  if ($skip > $#$ants) {
    for my $i ( 0 .. $#$ants - $skip ) {
      unshift @$ants, $chars->[0];
    }
  } else {
    for my $i ( 0 .. $#$ants - $skip ) {
      pop @$ants;
    }
  }
  if ( $marker == $skip ) {
    push @$chars, shift @$chars;
    $marker = 0;
  } else {
    $ants->[$marker++] = $chars->[0];
  }
  return join('',@$ants);
}

sub _ants_wave {
  no warnings 'uninitialized';

  our ( $ants, $chars, $marker, $skip );
  if ($skip > $#$ants) {
    for my $i ( 1 .. $#$ants - $skip) {
      unshift @$ants, $chars->[0]->[0];
    }
  } else {
    for my $i ( 1 .. $#$ants - $skip) {
      pop @$ants;
    }
  }
  if ( $marker == $skip ) {
    $ants->[$skip] = $chars->[0]->[1];
    push @$chars, shift @$chars;
    $marker = 0;
  } else {
    $ants->[$marker++] = $chars->[0]->[1];
    $ants->[$marker]   = $chars->[0]->[0];
  }
  return join('',@$ants);
}

sub _ants_wave_init {
  my $self = shift @_;
  my $c = shift @_;
  if ($c) {
    our $chars = $c;
  } else {
    our $chars = [ [ '\\', '~' ], [ '/', '_' ] ];
  }
}

sub _clock {
  my $self = shift @_;
  my $sec  = time - our $start;
  my $hr   = int($sec/3600);
     $sec -= $hr * 3600;
  my $min  = int($sec/60);
     $sec -= $min * 60;
  return join ':', map { $self->_zedten($_); } ($hr,$min,$sec);
}

sub _pcount {
  my $pretty = our $count;
  1 while $pretty =~ s/(\d)(\d\d\d)(?!\d)/$1,$2/;
  return $pretty;
}

sub _pinterval {
  my $pretty = our $interval;
  1 while $pretty =~ s/(\d)(\d\d\d)(?!\d)/$1,$2/;
  return $pretty;
}

sub _update {
  my $self = shift @_;
  our $name;
  my $in = $self->_pinterval;
  my $il = length $in;
  my $ct = $self->_pcount;
  my $cl = length $ct;
  if (our $term) {
    our $width = Term::Size::chars(*STDOUT{IO});
  } else {
    our $width = 80;
  }
  our $skip = our $width - 19 - $il - $cl - our $nl;
  my $format;
  my $out;
  if ($nl) {
    $format = "\r\%s \%${il}s : [\%${skip}s] \%${cl}s \%${nl}s ";
    $out = sprintf $format, $self->_clock, $in, $self->_ants, $ct, $name;
  } else {
    $skip++;
    $format = "\r\%s \%${il}s : [\%${skip}s] \%${cl}s ";
    $out = sprintf $format, $self->_clock, $in, $self->_ants, $ct;
  }
  $self->_update_interval;
  $format = "\%-.${width}s";
  return print STDERR sprintf $format, $out;
}

sub _update_interval {
  my $self = shift @_;
  my $now  = time;

  our ($interval, $last);
  my $delta = $now - $last;

  if ( $delta > 2 && $interval > 1 ) {
    $interval--;
  } elsif ( $delta < 1 ) {
    $interval++;
  }

  $last = time;
}

sub _zedten {
  my $self = shift @_;
  my $in   = shift @_;
  $in = '0'.$in if $in < 10 && $in > -1;
  return $in;
}

1;
