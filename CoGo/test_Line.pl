use My::CoGo::Point;
use My::CoGo::Line;
use feature 'say';
use Data::Dumper;
use Carp qw( confess ) ;
use Math::Trig qw( pi rad2deg deg2rad );

my @clock;
foreach my $i ( 0 .. 11) {
  my $angle = deg2rad $i/12 * 360;
  my $r = 10;
  my $x = $r *  cos($angle);
  my $y = $r *  sin($angle);
#  say "$x   $y";
  push @clock, Point->new(N => $x, E=> $y );
}
my   $b=Line->new(pa=>$clock[0], bearing => 0.1 );
say  "bearing of \$b: ", $b->bearing ;
say  "normal  of \$b: ", $b->normal;
say Dumper  $b->offset(2);
say Dumper  $b->offset(-20);
