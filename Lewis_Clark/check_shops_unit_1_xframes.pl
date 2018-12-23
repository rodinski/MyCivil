use strict;
use Math::Round;
use My::Civil qw( feet2callout format_STA );
use feature 'say';
use Scalar::Util qw( looks_like_number );
use YAML qw( LoadFile Load DumpFile Dump); #LoadFile isn't exported by default
use Data::Dumper;

our ($pt) = LoadFile('./all_cogo_pts.yaml');

if (1 == 1) {
    my $inset_to_hole = ( 0.25 + 3.5 + 3.5 + 0.25 ) / 12.0;
    # setup to loop over unit 1 on BR 340 only G05
    # to G5 to G11
    my $l_over = 11/12.0;  # left overhang
    my @nth = qw (  BA01 BB02 ); 
    my @girders = qw( 05 06 07 08  09 10 11 );


    for my $n ( 0 .. 1 ) {
        say "\nLocation n: $nth[$n]";
        for my $g ( 0 .. 5  ) { 
              my $p0 =  $nth[$n].$girders[$g];
              my $p1 =  $nth[$n].$girders[$g + 1];


              my $d_n    = $pt->{$p0}{n}    - $pt->{$p1}{n};
              my $d_e    = $pt->{$p0}{e}    - $pt->{$p1}{e};
              my $d_deck = $pt->{$p0}{deck} - $pt->{$p1}{deck};
              my $ss = sq_ss ( $d_n, $d_e );
              my $h_spa = $ss - $inset_to_hole;
              printf  "Girder %s  %15s  %15s %15s  \n",
                       $p0, feet2callout($ss), feet2callout($h_spa), feet2callout($d_deck) ;
          }
    }

    say;
    my @j = qw ( G0505  G0605  G0705  G0805  G0905  G1005  G1105 );
    for my $g ( 0 .. 5 ) {
        my $p0 = $j[$g];
        my $p1 = $j[$g + 1 ];
        my $d_n    = $pt->{$p0}{n}    - $pt->{$p1}{n};
        my $d_e    = $pt->{$p0}{e}    - $pt->{$p1}{e};
        my $d_deck = $pt->{$p0}{deck} - $pt->{$p1}{deck};
        my $ss = sq_ss ( $d_n, $d_e );
        my $h_spa = $ss - $inset_to_hole;
        printf  "Girder %s  %15s  %15s %15s   %7.2f   %7.2f\n",
                 $p0, feet2callout($ss), feet2callout($h_spa), feet2callout($d_deck), $pt->{$p0}{deck}, $pt->{$p1}{deck} ;
    }

}




#  calc sqrt of the sum of th squares
#  input is a list of delta_lengts
sub sq_ss {
    my $sum = 0;
    while ( @_ ){ $sum +=  shift()**2 }
    return sqrt( $sum );
}
