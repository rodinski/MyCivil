use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my %HoA = ( spans => [ 54.25, 77, 77, 54.25 ] );

#my %HoA =( spans => [ 100, 50, 100 ] );
$HoA{e}   =-3.25;
$HoA{end} =-(9+7/8.);
$HoA{pier}= (8./2);

my @b = (   [1.5            , 2.5, 1.24 , 9.33   ]
          , [1.5 + 2.5 *4 , 6.0, 1.24 , 9.33   ]
          , [17.5         , 10 , 1.24 , 9.33   ]
          , [27.5         , 8.5, 0.4  , 9.33  ]
          , [36           , 8  , 0.4  , 9.33  ]
          , [44           , 18 , 0.4  , 0.0  ]
       );

#my @b = (  [ 1.5, 1, 1.1, 9.33 ]
#         , [ 12, 2, 12, 9.33 ]
#         , [ 36, 3, 36, 9.33 ] );
#$HoA{e}    = -.5;
#$HoA{end}  = -3;
#$HoA{pier} = 50;
my $end_span = scalar @{ $HoA{spans} }; 
foreach my $memb ( 1 .. $end_span ) {
    say "";
    my @sec;
    my $cnt     = 0;
    my $s       = $HoA{spans}[ $memb - 1 ];
    my $end_bar = scalar @b;

    foreach my $i ( 1 .. $end_bar ) {

        my $dist_f_end = $b[ $i - 1 ][0];
        my $sp         = $b[ $i - 1 ][1];
        my $area       = $b[ $i - 1 ][2];
        my $Sx         = $b[ $i - 1 ][3];
        my @line;

        my $lf_bm_end = $HoA{pier};    #assume pier
        my $rt_bm_end = $HoA{pier};    #assume pier
        for my $end ( "L", "R" ) {
            if ( $memb == 1 && $end eq "L" )         { $lf_bm_end = $HoA{end} + $HoA{e}; }
            if ( $memb == $end_span && $end eq "R" ) { $rt_bm_end = -$HoA{end} + $HoA{e}; }
            # now I have end of beam locastion relative to all support points

            if ( $end eq "R" && $i == $end_bar ) { next }    #skip second version of last spacing
                 # it doesn't get reported

            my $l;    #distance to go in bdf file

            if ( $end eq "L" ) { $l = $lf_bm_end + $dist_f_end }
            if ( $end eq "R" ) { $l = $s * 12 - $rt_bm_end - $dist_f_end }

            if ( $end eq "x" ) { print "==  $sp   $lf_bm_end   $dist_f_end  $l \n"; }
            if ( $end eq "x" ) { my $tmp_s = $s * 12.0; print "==  $sp   $rt_bm_end   $dist_f_end  $tmp_s   $l \n"; }

#            if ( $end eq "L" && $l < 0 ) { @sec = (); $l   = 0.0; }    # when $l is neg empty @sec
#            if ( $end eq "L" && scalar @sec == 0 ) { $l = 0.0; }    # first dist must be 0.0
            push @line, sprintf "%3d %6.2f  L    %5.2f  %6.2f  %5.2f\n",
              , $memb, $l / 12., $sp, $area, $Sx;

        }
        my $insert = ( scalar @sec ) / 2  ;
        splice @sec, $insert, 0, @line;
#<>; print @sec;
        $cnt++;
    }
    #clean up negative DIST values 
    my @clean;
    my $j = 0;
    for my $val ( @sec ) { 

      if ($j == 0 && $val !~ /-/ ) { #is the fisrt DIST > 0 
        my @f = split /\s+/,$val ;
        if ($f[2]>0) {push @clean, ( "*".$val) }
        $val = "0.0me".$val;
      }

      if ($val =~ /-/ ) {  
        push @clean, ( "*".$val ) ;
        if ( $sec[$j+1] !~ /-/ ) { push @clean, ( "0.0me".$val) }
      }

      else              { push @clean, $val }
      $j++;
    }
    print @clean;
}

#print Dumper \%HoA;
__END__

90-147  DATA:
        $HoA{e}   =-3.25;
        $HoA{end} =-(9+7/8.);
        $HoA{pier}= (8./2);

        my @b = (   [1.5            , 2.5, 1.24 , 9.33   ]
                  , [1.5 + 2.5 *4 , 6.0, 1.24 , 9.33   ]
                  , [17.5         , 10 , 1.24 , 9.33   ]
                  , [27.5         , 8.5, 0.4  , 9.33  ]
                  , [36           , 8  , 0.4  , 9.33  ]
                  , [44           , 18 , 0.4  , 0.0  ]
               );
