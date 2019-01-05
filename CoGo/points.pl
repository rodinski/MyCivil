use strict;
use warnings;
use feature ( 'say' ) ; 
use Data::Dumper;
use My::Cogo::Point;
use My::Cogo::Ray;


my $p = Point->new(x => 3, y => 4);
my $p1 = Point->new(x => 30, y => 40);

say $p->x; say $p->y;
say ref  $p;
say ref  $p;
say Dumper $p;
#say $p->coordinates;
#say $p->distance_from_o;
#
#say $p->move_by(10,10);
#say $p->coordinates;
#say $p->bearing_from_0;



my $r = Ray->new( {name => 'newName',point => $p } );
say Dumper $r;
use Bearing;
my $bear = Bearing->new(bearing=>-1.5);
say Dumper $bear;
say $bear->bearing  ;
say $bear->deg ;


say join "\n", @INC;
