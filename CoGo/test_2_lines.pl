use My::CoGo::Line;
use My::CoGo::Point;
use My::CoGo::Segment;
use strict;
use warnings;
use feature 'say' ;
use Data::Dumper;


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

my $sa = Segment->new( pa => $clock[0] , pb => $clock[4] );
my $sb = Segment->new( pa => $clock[9] , pb => $clock[5] );

my $int_pt = intersect ( $sa, $sb );
say Dumper $int_pt;

sub intersect {
    my $seg_1 = shift;
    my $seg_2 = shift;
    #say Dumper $seg_1;
    #
       

    my $d_N = $seg_2->pa->N - $seg_1->pa->N ;
    my $d_M = $seg_1->bearing - $seg_2->bearing ;
    if ( $d_M == 0 ) { return "Lines are parallel, no cross point"; }
    my $t1 =  $seg_1->bearing * $seg_1->pa->E ;
    my $t2 =  $seg_2->bearing * $seg_2->pa->E ;


    my $x = ( $d_N + $t1 - $t2 ) /  $d_M ;  
    my $y =      $seg_1->bearing * ($x - $seg_1->pa->E) + $seg_1->pa->N ;
    my $y_chk =  $seg_2->bearing * ($x - $seg_2->pa->E) + $seg_2->pa->N ;
    #say "$x\t $y \t $y_chk";
    my $new_pt = Point->new( N => $y, E => $x ) ;
    return $new_pt;
    }
