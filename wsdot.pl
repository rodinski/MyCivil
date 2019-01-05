use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my %HoA =( spans => [ 54.25, 77, 77, 54.25 ] );
$HoA{e}   =-3.25;
$HoA{end} =-(9+7/8.);
$HoA{pier}= (9+7/8.);

my @b = (   [0            , 2.5, 1.24 , 9.33   ]
          , [1.5 + 2.5 *4 , 6.5, 1.24 , 9.33   ]
          , [17.5         , 10 , 1.24 , 9.33   ]
          , [27.5         , 8.5, 0.4  , 9.33  ]
          , [26           , 8  , 0.4  , 9.33  ]
          , [34           , 16 , 0.4  , 0.0  ]
       );

foreach my $memb ( 1 .. scalar @{ $HoA{spans}  } ) {
  my $s = $HoA{spans}[$memb -1 ];
  my $lf_correction = $HoA{e} ;
  # left correction
  if ($memb == 1) { $lf_correction += $HoA{end} }
  else            { $lf_correction += $HoA{pier} } 


  say "";
          my @sec ;
          my $cnt = 0;
            foreach my $i ( 1 .. scalar @b ) {
              my $l    = $b[$i-1][0] + $lf_correction ;
              my $sp   = $b[$i-1][1];
              my $area = $b[$i-1][2];
              my $Sx   = $b[$i-1][3];
              my @line;
              for my $end ( 0,1) {
                if ($end==1 && $i == scalar @b ) {next}  #skip second version of last spacing

                if ($end==1) { $l =  $s*12 - $b[$i][0]  ; } 
                if ($end==0 && $l < 0)             { @sec =();  $l = 0.0 }    # when $l is neg empty @sec 
                if ($end==0 && scalar @sec == 0)   {  $l = 0.0  }   # first dist must be 0.0 

                push @line, sprintf "%3d %6.2f  L    %5.2f  %6.2f  %5.2f\n", 
                                    ,$memb, $l/12., $sp, $area, $Sx; 

                }
                my $insert = (scalar @sec) / 2  ;
                splice @sec,$insert, 0, @line;
            $cnt++
            }
            print @sec;
}
print "L of sec ". scalar @b. "\n";

#print Dumper \%HoA; 
__END__

90-147  DATA:
                        my %HoA =( spans => [ 54.25, 77, 77, 54.25 ] );
                        $HoA{e}   =-3.25;
                        $HoA{end} =-(9+7/8.);
                        $HoA{pier}= (9+7/8.);

                        my @b = (   [0            , 2.5, 1.24 , 9.33   ]
                                  , [1.5 + 2.5 *4 , 6.5, 1.24 , 9.33   ]
                                  , [17.5         , 10 , 1.24 , 9.33   ]
                                  , [27.5         , 8.5, 0.4  , 9.33  ]
                                  , [26           , 8  , 0.4  , 9.33  ]
                                  , [34           , 16 , 0.4  , 0.0  ]
                               );
