use My::CoGo::Point;
use My::CoGo::Segment;
#use My::CoGo::Line;
use warnings;
use strict;
use Data::Dumper;
use Math::Trig qw ( pi rad2deg deg2rad );
use feature 'say' ;
my @clock;
foreach my $i ( 0 .. 11) {
  my $angle = deg2rad $i/12 * 360;
  my $r = 10;
  my $x = $r *  cos($angle);
  my $y = $r *  sin($angle);
#  say "$x   $y";
  push @clock, Point->new(N => $x, E=> $y );
}
my   $s=Segment->new(pa=>$clock[4], pb=>$clock[3] );

#say Dumper $s;
say $s->length;
say $s->bearing;
say $s->d_N;
say $s->d_E;
say $s->normal;
