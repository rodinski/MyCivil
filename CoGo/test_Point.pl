use My::CoGo::Point;
my @p;
use feature 'say';
use Data::Dumper;
use Carp qw( confess ) ;

push @p, Point->new(N => 10, E=> 9.5);
push @p, Point->new(N => 3, E=> -9.25);
my $pt = $p[0];



if ( 0 ) {
  say $pt->to_string;
  say $pt->N;
  say $pt->E;
  say $pt->bearing_from_N;
}
$pt->translate( 129,0);
say $pt->to_string;

use My::CoGo::Segment;
my $seg = Segment->new( pt0 =>  $p[1], pt1=>$p[0] );
if ( 0 ) {
  say $seg->distance;
  printf "%s  %s\n", $seg->d_E, $seg->d_N  ;
  say $seg->bearing;
#  say Dumper $seg;
}

use My::CoGo::Arc;
my $arc = Arc->new( pt0 =>  $p[1], pt1=>$p[0], delta_angle => .6 );
say Dumper $arc;
say $arc->pt_end
