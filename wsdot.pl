use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my %HoA =( spans => [ 55.5, 80, 80, 55.5 ] );

my %gap = ( end  => -.75
          ,  pier =>  .75
          ) ;

foreach my $memb ( 1 .. scalar @{ $HoA{spans}  } ) {
  my $s = $HoA{spans}[$memb -1 ];
#  say "$memb  $s";
}
my $s = 50.0;
my $e = 3.2;
my @b = (   [0            , 2.5 ]
          , [1.5 + 2.5 *4 , 6.5]
          , [17.5         , 10]
          , [27.5 , 8.5]
          , [26 , 8]
          , [34 , 16]
       );

#foreach my $memb ( 1 .. scalar @{ $HoA{spans}  } ) {
#  my $span = $HoA{spans}[$memb -1 ];
#  say "Member $memb  $span";
  my $area = 0.4;
  my $Sx = 9.5;
  my @sec ;
  my $cnt = 0;
    foreach my $i ( 1 .. scalar @b ) {
      my $l = $b[$i-1][0];
      my $sp =  $b[$i-1][1];
      my @line;
      for my $end ( 0,1) {
        if ($end==1 && $i == scalar @b ) {next} 

        if ($end) { $l =  $s*12 - $b[$i][0]; } 
        push @line, sprintf "%6.2f  L   %5.2f  %6.2f  %5.2f\n", 
                            $l/12., $sp, $area, $Sx; 
        }
        my $insert = (scalar @sec) / 2  ;
        #push @sec, @line;
        splice @sec,$insert, 0, @line;
    $cnt++
    }
#}
print "L of sec ". scalar @b. "\n";
print  @sec;
#print Dumper \%HoA; 
