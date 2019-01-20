use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my %HoA = ( spans => [ 54.25, 77, 77, 54.25 ] );
$HoA{e}   =-3.25;
$HoA{end} =-(9+7/8.);
$HoA{pier}= (8./2);

my @b = (   [1.5            , 2.5, 1.24 , 9.33   ]
          , [1.5 + 2.5 *4 , 6  , 1.24 , 9.33   ]
          , [17.5         , 10 , 1.24 , 9.33   ]
          , [27.5         , 8.5, 0.4  , 9.33  ]
          , [36           , 8  , 0.4  , 9.33  ]
          , [44           , 18 , 0.4  , 0.0  ]
       );



my $end_span = scalar @{ $HoA{spans} }; 
foreach my $memb ( 1 .. $end_span ) {
    say "";
    my @sec;
    my $cnt     = 0;
    my $s       = $HoA{spans}[ $memb - 1 ];
    my $end_bar = scalar @b;

    foreach my $i ( 1 .. $end_bar ) {
        my $dist_f_end = $b[ $i - 1 ][0];

        my $next_gap   =  0;
        # note $i-1  is the current information
        if ($i != $end_bar) { $next_gap   = $b[ $i ][0] - $b[ $i - 1 ][0]} ;

        my $sp         = $b[ $i - 1 ][1];
        my $area       = $b[ $i - 1 ][2];
        my $Sx         = $b[ $i - 1 ][3];
        my @line;

        my $lf_bm_end = $HoA{pier};    #assume pier
        my $rt_bm_end = $HoA{pier};    #assume pier
        for my $end ( "L", "R" ) {
            if ( $memb == 1  )         { $lf_bm_end = $HoA{end} + $HoA{e}; }
            if ( $memb == $end_span  ) { $rt_bm_end = +$HoA{end} + $HoA{e}; }
            # now I have end of beam locastion relative to all support points
            #
            #      |____________bm_length______________|    = -lf_bm_end +s +rt_bm_end
            #         ^              s                    ^
            #           |____________bm_length______________|    = -lf_bm_end +s +rt_bm_end
            #         ^              s                        ^
            #           |____________bm_length______________|    = -lf_bm_end +s +rt_bm_end
            #         ^              s                    ^
            my $bm_length = -$lf_bm_end +$s*12 -$rt_bm_end;   #bars mirro about $bm_length not $s
            if ( $end eq "R" && $i == $end_bar ) { next }    #skip second version of last spacing
                 # it doesn't get reported

            my $l;    #distance to go in bdf file

            if ( $end eq "L" ) { $l = $lf_bm_end + $dist_f_end }
            if ( $end eq "R" ) { $l = $s * 12 - $rt_bm_end - $dist_f_end }

            if ( $end eq "R" ) { 
                    # first find where it is on $bm_length only
                    # because we come from the left side only subtract the  gap
                    #  ( sym ) less next_gap
                    my   $bm_l = ($bm_length - $dist_f_end )-$next_gap ;
                    $l = $bm_l + $lf_bm_end;
            }



            if ( $end eq "x" ) { print "==  $sp   $lf_bm_end   $dist_f_end  $l \n"; }
            if ( $end eq "x" ) { my $tmp_s = $s * 12.0; print "==  $sp   $rt_bm_end   $dist_f_end  $tmp_s   $l \n"; }

#            if ( $end eq "L" && $l < 0 ) { @sec = (); $l   = 0.0; }    # when $l is neg empty @sec
#            if ( $end eq "L" && scalar @sec == 0 ) { $l = 0.0; }    # first dist must be 0.0
            my $tmp_line="";
            if ($l >= $s*12.0 ) { $tmp_line = "*" }  #did we go beyond $s? 
            $tmp_line .= sprintf "%3d %6.2f  L    %5.2f  %6.2f  %5.2f\n",
                                  , $memb, $l / 12., $sp, $area, $Sx;

            push @line, $tmp_line;
        
            #print "$lf_bm_end    $s     $rt_bm_end     ".  $bm_length/12.0. "\n";

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
                        my %HoA =( spans => [ 54.25, 77, 77, 54.25 ] );
                        $HoA{e}   =-3.25;
                        $HoA{end} =-(9+7/8.);
                        $HoA{pier}= (9+7/8.);

                        my @b = (   [0            , 2.5, 1.24 , 9.33   ]
                                  , [1.5 + 2.5 *4 , 6.5, 1.24 , 9.33   ]
                                  , [17.5         , 10 , 1.24 , 9.33   ]
                                  , [27.5         , 8.5, 0.4  , 9.33  ]
                                  , [36           , 8  , 0.4  , 9.33  ]
                                  , [44           , 16 , 0.4  , 0.0  ]
                               );
%HoA =( spans => [ 54.25, 77, 77, 54.25 ] );
%HoA =( spans => [ 100, 100 ] );
$HoA{e}   =-3.25;
$HoA{end} =-(9+7/8.);
$HoA{pier}= (9+7/8. + 8./2);
$HoA{e}   =-3;
$HoA{end} =-(9);
$HoA{pier}= (15);

my @b = (   [0            , 1, 1.24 , 9.33   ]
          , [12           , 2, 1.24 , 9.33   ]
          , [36           , 3, 1.24 , 9.33   ]
       );
#my @b = (  [ 1.5, 1, 1.1, 9.33 ]
#         , [ 12, 2, 12, 9.33 ]
#         , [ 36, 3, 36, 9.33 ] );
#$HoA{e}    = -.5;
#$HoA{end}  = -3;
#$HoA{pier} = 50;
