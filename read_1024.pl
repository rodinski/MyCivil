use strict;
use warnings;
use feature 'say';
use My::Civil qw( bar_a feet2callout )  ;
use Data::Dumper;
my %p = ( '1' => 0, '2'=>77, '3'=>154 ) ;
#==   ===.==  ======   ==  ====.==    =    ===.==  ==.==   ==.==  ==.==  |  =      =     |   =      =     |
my $ln;
no warnings;
until ( $ln =~ /^=== / ) { $ln = <DATA>  }
use warnings;

my @AoA;
while ( $ln = <DATA>  ) {
  chomp $ln;
  #say $ln;
  if ($ln !~/[0-9]/)   { next }
  my @d = unpack ("A3 x3 A6 x2 A6 x3 A2 x2 A7 x4  A x4 A6 x2 A5 x3 A5 x2  A5 x5  A x6 A x9 A x6 A" , $ln);
      my $memb =  &trim($d[0]);
      my $dist =  &trim($d[1]);
      my $barsz = &trim($d[3]);
      my $no =    &trim($d[4]);
      my $l =     &trim($d[6]);
      my $area  = bar_a($barsz) * $no;
      my $start = $dist  + $p{$memb};
      my $end =   $start + $l ;
      push @AoA,  [ ($start, $area ) ] ;
      push @AoA,  [ ($end  , -$area) ] ;
#      say " memb:$memb dist:$dist  bar_a:  $area   s: $start  e: $end "  ;
      
}
#say @AoA;

my @sort = sort { $a->[0] <=> $b->[0] }   @AoA ;
#need to report each delta_x and delta_y
say "0.0\t0.0";
my ($run_x, $run_y) = ( 0.0, 0.0 );
foreach my $i ( 0 .. $#sort   ) {
        printf "%6.2f\t%6.2f\n",   $sort[$i][0],  $run_y ; 
        $run_y += $sort[$i][1];
        printf "%6.2f\t%6.2f\n",   $sort[$i][0],  $run_y ; 
}

#say Dumper @barray;
#say $barray[0][0] ;
#say $barray[0][1] ;
#say join "  ", @barray;
#print join "\n", sort { $barray[$a][0] <=>  $barray[$b][0] } @barray;


sub ltrim { my $s = shift ; $s =~ s/^\s+//g;  return $s }
sub rtrim { my $s = shift ; $s =~ s/\s+$//g;  return $s }
sub trim  { my $s = shift ; $s =~ s/^\s+|\s+$//g; return $s }


__DATA__
* =============================================================================================================================
# [TOP STEEL(B)]         1024  <Top Steel (Neg.Mom.) Alternate Entry Method>
* ==================================================================================================================================
*
* MARK:            For user reference only, not used by the program.
* START:           May start with a negative number (i.e. before member start or run past end of member or bridge.
* END TYPE:        Standard Hook = H,  Straight = S.
* DEFAULT VALUES:  Splice Class = N, Epoxy Coat = N, End Type = S.
* COVER ABOVE BAR is measured to the top of the bar
* COVER BELOW BAR is measured to the bottom of the bar
*
* --------- SPLICE CLASSES --------
* A = Class A Splice
* B = Class B Splice
* C = Class C Splice
* F = Field Weld
* M = Mechanical Splice
* N = Not Spliced
* H = Use AASHTO 8.29.3.2 Criteria ( applicable for hooks only ).
*
                                                           COVER  COVER  | LEFT END COND | RIGHT END COND |
                      BAR   NUMBER  EPOXY  BAR     LATRL.  ABOVE  BELOW. |               |                |
 MBR  START    MARK   SIZE    OF    COAT   LENGTH  SPAC.   BAR    BAR    | END   SPLICE  |  END   SPLICE  |
 #    (ft)    NUMBER   ##    BARS   (Y/N)  (ft)    (in)    (in)   (in)   | TYPE  CLASS   |  TYPE  CLASS   |
===   ===.==  ======   ==  ====.==    =    ===.==  ==.==   ==.==  ==.==  |  =      =     |   =      =     |
  1    -1.25     601    4    42       N    175.5   12       4.37   1.63     S      N         S      C

  1    -1.25     605   11    12.      N     21.92  12.      2.25   9.75     S      N         S      C
  1    18.34     605   11    12.      N     18.33  12.      2.25   9.75     S      C         S      C
  1    34.34     606   14    12.      N     22.5   12.      2.25   9.75     S      C         S      C
  2   -21.83  613614   14    12.      N     43.83  12.      2.25   9.75     S      C         S      C
  2    19.       616   14    12.      N     23.17  12.      2.25   9.75     S      C         S      C
  2    39.34     616   14    12.      N     19.    12.      2.25   9.75     S      C         S      C
  3   -21.5   621622   14    12.      N     35.33  12.      2.25   9.75     S      C         S      C
  3    11        625   14    12.      N      6.17  12.      2.25   9.75     S      C         S      N

*  web corner
  2    -6.00     607   14    12.      N     12.    10.      4.25   3.75     S      C         S      C
  2    -8.00     608   14    12.      N     16.    10.      4.25   3.75     S      C         S      C
  2   -10.00     609   14    12.      N     20.    10.      4.25   3.75     S      C         S      C
  2   -12.00     610   14    12.      N     24.    10.      4.25   3.75     S      C         S      C
  2   -14.00     611   14    12.      N     28.    10.      4.25   3.75     S      C         S      C
  2   -18.00     612   14    12.      N     36.    10.      4.25   3.75     S      C         S      C
*  uni mid span
  1    -1.25     600    4    40       N     78.25  10       4.25   3.75     S      C         S      C

  2   -21.83            4     5.      N     16.92  10.      4.25   3.75     S      C         S      C
  2   -21.83            4    10.      N     12.92  10.      4.25   3.75     S      C         S      C
  2   -21.83            4     5.      N      8.92  10.      4.25   3.75     S      C         S      C
  2   -21.83            4     5.      N      5.92  10.      4.25   3.75     S      C         S      C
  2   -21.83            4     5.      N      4.92  10.      4.25   3.75     S      C         S      C
  2   -21.83     615   14    10.      N     46.     6       4.25   3.75     S      C         S      C

  3   -17.0      620   14    12       N     31.     6       4.25   3.75     S      C         S      C
  3   -12.0      619   14    12       N     22.     6       4.25   3.75     S      C         S      C
  3    -8.0      618   14    12       N     15.     6       4.25   3.75     S      C         S      C
  3    -5.0      617   14    12       N     10.     6       4.25   3.75     S      C         S      C

  3    -1.       623    8     2       N     16.    10       4.25   3.75     S      C         S      C
  3   -17.       624    8     2       N     31.75  10       4.25   3.75     S      C         S      C
