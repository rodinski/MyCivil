use strict;
use Math::Round;
use My::Civil qw( feet2callout format_STA );
use feature 'say';
use Scalar::Util qw( looks_like_number );
use YAML qw( LoadFile Load DumpFile Dump); #LoadFile isn't exported by default
use Data::Dumper;

our ($pt) = LoadFile('./all_cogo_pts.yaml');

if (1 == 1) {
    # setup to loop over unit 1 on BR 340 only G05
    # to G5 to G11
    my $l_over = 11/12.0;  # left overhang
    my @girders = qw( G05 G06 G07 G08  G09 G10 G11 );
    for my $g ( 0 .. 6 ) { 
      my $steel_len = 0; 
      for my $j (0 .. 10 ){ 
          my $p0 = sprintf "%s%02d", $girders[$g],$j;
          my $p1 = sprintf "%s%02d", $girders[$g],$j+1;
          my $d_deck = $pt->{$p0}{deck} - $pt->{$p1}{deck};
          my $d_e    = $pt->{$p0}{e}    - $pt->{$p1}{e};
          my $d_n    = $pt->{$p0}{n}    - $pt->{$p1}{n};
          my $ss = sq_ss ( $d_deck, $d_n, $d_e );
          $steel_len += $ss;

          printf "%s   %7.3f   %7.3f   %7.3f   %7.3f %15s %15s\n", 
                  $p0 , $d_n, $d_e,   $d_deck,  $ss, feet2callout($steel_len), 
                                                    feet2callout($steel_len + $l_over);
      #
              }
      printf "length = %s\n" ,feet2callout($steel_len,32); 
        }

}
say;

#  calc sqrt of the sum of th squares
#  input is a list of delta_lengts
sub sq_ss {
    my $sum = 0;
    while ( @_ ){ $sum +=  shift()**2 }
    return sqrt( $sum );
}
