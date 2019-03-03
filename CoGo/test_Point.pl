use My::CoGo::Point;
use feature 'say';
use Data::Dumper;
use Carp qw( confess ) ;
use Math::Trig qw( :pi rad2deg deg2rad );


my @p;
push @p, Point->new(N => 10, E=> 9.5);
push @p, Point->new(N => 3, E=> -9.25);
my $pt = $p[0];


my @clock;
foreach my $i ( 0 .. 11) {
  my $angle = deg2rad $i/12 * 360;
  my $r = 10;
  my $x = $r *  cos($angle);
  my $y = $r *  sin($angle);
#  say "$x   $y";
  push @clock, Point->new(N => $y, E=> $x );
}
my @xdata = map  { $_->{'E'} }  @clock;
my @ydata = map  { $_->{'N'} }  @clock;
print join " " , @xdata, @ydata ;

use Chart::Gnuplot;

my $chart = Chart::Gnuplot->new( 
       output=> './test_Point.gif' ,
       terminal => 'svg mousing' , 
          xdata=> \@xdata, ydata=> \@ydata  
      );
#print Dumper \$chart; 
$chart->plot2d(  data=>[0,1] );

my $ds=Chart::GNuplot::DataSet->new();

#for my $i ( 1 .. 6 ) {
#  $pt->translate( $i*2,$i);
#  say $pt->to_string;
#  $pt->rotate( deg2rad ($i * 2));
#  say $pt->to_string;
#}
#say $clock[0]->to_string;
#$clock[0]->rotate(  angle => deg2rad( 20 )   );
#say $clock[0]->to_string;
#$clock[0]->rotate(  angle => deg2rad( -20 )   );
#say $clock[0]->to_string;

#print Dumper @clock;
#say $clock[0]->to_string;
##translate  changes the points N&E
#$clock[2]->translate(   dN => 100, dE => -0  );
#say $clock[2]->to_string;

use My::CoGo::Segment;
my $seg = Segment->new( pt0 =>  $p[1], pt1=>$p[0] );
#print $seg->length;

use My::CoGo::Curve;
my $cur = Curve->new( 
    PC=>$p[0]
  , CC=>$p[1]
  , delta_angle=>0.11
);
#print Dumper $cur;
#say "cur->R : " . $cur->r;

#print  $cur->R;

if ( 0 ) {
  say $pt->to_string;
  say $pt->N;
  say $pt->E;
  say $pt->bearing_from_N;
}

if ( 0 ) {
  say $seg->distance;
  printf "%s  %s\n", $seg->d_E, $seg->d_N  ;
  say $seg->bearing;
#  say Dumper $seg;
}

if ( 0 ) {
use My::CoGo::Arc;
my $arc = Arc->new( pt0 =>  $p[1], pt1=>$p[0], delta_angle => .6 );
say Dumper $arc;
say $arc->pt_end;
}

if ( 0 ) {
use My::CoGo::Ray;
my $ray = Ray->new( name => 'rayname',  point =>  $p[0],  bearing => .1123 ) ;
say $ray->bearing();
say $ray->bearing( 2.3 );
say "name:$ray->name()  bearing:$ray->bearing()    () Don't work!";
printf  "name: %s bearing: %s\n", $ray->name(),  $ray->bearing();
}
