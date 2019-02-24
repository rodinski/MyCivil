use strict;
use Math::Trig;
use Math::Round;
use feature 'say';
use Scalar::Util qw( looks_like_number );
use YAML qw( LoadFile Load DumpFile Dump); #LoadFile isn't exported by default
use Data::Dumper;

our ($xs) = LoadFile('./super_el_LCE.yaml');


#get all the staions
our @sta;  #list of station with breaks in slope
for my $hashref (@$xs) {
	#say $hashref. "   ".   $hashref->{sta}; 
	push @sta, $hashref->{sta};
}
#print  join " ", @sta;
our @deltaL;  # get the length b/w each know xslope break locations
for (my $i=0; $i<=(scalar @sta)-2; $i++) {
	push @deltaL , nearest(0.01, $sta[$i+1] - $sta[$i]);
}	

#use function that send sta and returns list of offsets and slopes 
#    el_from_left( one , two )
#    one =  some offset in ft
#    two =  the array returned by the   find_sec($station)  subroutine
# so to get a correction take the el_from of the ind_offset and subtract
# the el_from left of the offset where zero is crosses.
# like:
#   el_from_left($y, find_sec($loc)) ." - ". el_from_left(0, find_sec($loc))
# 
# for (my $loc = 12950.44; $loc < 13990.44; $loc+=5 ) {
# 	say  "Sta $loc  -> ",  ( join " ", find_sec($loc) );
# 	say se_corection (10, find_sec($loc) ); 
# }
#
#

my $filename;
$filename="./../LewisClark/output/lce_99213.orh";

open (my $fh, "<", $filename) 
          or die "Connot open file : $!";

my $girder;  #a reference to a hash of hashes
# starting with girder number in the form of
# 124 = ahead of bent 12, 4th gider
my $cogo_pts;   #a reference to a hash of hashes

say "point\tSTA\tSTA\toffset\tProG\tsuper\tTODeck";
while ( <$fh> ) {
	
my $pt;
my $loc;
my $y;
my $n;
my $e;
my $offset;
	chomp;

	my @line = split ; #read an cogo INVERSE line
	$pt  =  $line[0];





	#deal with BA=Bearing ahead these end in 
    #only deal with the line if $pt is defined 
	#and it's value starts with G BA or BB and finishes with only numbers
	unless ( defined $line[6] && looks_like_number $line[6] && $line[6]=~/\d\.\d\d/ ) {next};
	# additional checks
	unless ( defined $line[4] && looks_like_number $line[4] &&  $line[4] == 1  ) {next};

	# set the $girder_numb and $nth  based on the name of the $pt
    # first case is it only numeric?
	# Unit 1 is going to get numbers like G####  ##-bnt  ##-point
	

if (1==0) {
	my $girder_numb;
	my $nth;
	my $test_pt = $pt;
    if ( $test_pt =~ /^\d+$/ ) {  #match only numbers
		$girder_numb = int($pt / 100);
		$nth = $pt - ( $girder_numb * 100 );
		if ($girder_numb < 99) {$girder_numb = '0'.$girder_numb};
	}
	elsif ( $test_pt =~ /^G\d+$/ ) {   #match only starts with G followed by numb
		$girder_numb = sprintf "G%02d",substr($pt,1,2)  ;
		$nth = substr($pt,-2);
		$pt = "U1".$pt;   #change the cogo point name
        
	}
	elsif ( $test_pt =~ /^BA\d+$/ )  { # match only starts with BA then numb
		$girder_numb = sprintf "G%02d",substr($pt,-2)  ;
		#say "\npulled girder_numb $girder_numb  from $pt";
		$nth = "00";
		my $temp_bnt = sprintf "%d",substr($pt,3,1) - 0 ;  #get bnt as a number not text
		$pt = "U".$temp_bnt.$girder_numb.$nth;   #change the cogo point name
	}
	elsif ( $test_pt =~ /^BB\d+$/ )  { # match only starts with BA then numb
		$girder_numb = sprintf "G%02d",substr($pt,-2)  ;
		$nth = "10";
		my $temp_bnt = sprintf "%d",substr($pt,3,1) - 1 ;  #get bnt as a number not text
		$pt = "U".$temp_bnt.$girder_numb.$nth;   #change the cogo point name
	}
	elsif ( $test_pt =~ /^CF\d+$/ )  { # match Cross Frames 
		$girder_numb = sprintf "G%02d",substr($pt,-2)  ;
		$nth = "10";
		my $temp_bnt = sprintf "%d",substr($pt,3,1) - 1 ;  #get bnt as a number not text
		$pt = "U".$temp_bnt.$girder_numb.$nth;   #change the cogo point name
	}
}



		   #if ( $pt !~ /^\d\+$/ ) { next } #line if $pt not a number
	$n  =  $line[1];
	$n =~  s/,//g;   #strip the commas
	$e  =  $line[2];
	$e =~  s/,//g;   #strip the commas
    $loc =   $line[3];
	$loc =~ s/\+// ;  #strip the +
    $y =  nearest(0.01,$line[5]);
		
    $cogo_pts->{$pt}{'pt'} = $pt;
	$cogo_pts->{$pt}{'sta'} = $loc;
	$cogo_pts->{$pt}{'offset'} = $y;
	$cogo_pts->{$pt}{'n'} = $n;
	$cogo_pts->{$pt}{'e'} = $e;
	$cogo_pts->{$pt}{'f_sta'} = format_STA($loc);
	$cogo_pts->{$pt}{'ProG'} = nearest(0.001,ProG($loc));

	my $se_c = el_from_left($y, find_sec($loc))- el_from_left(0, find_sec($loc));
	$cogo_pts->{$pt}{'se_c'} = nearest(0.001,$se_c);

    printf "%8s\t%8.2f\t%s\t%8.2f\t%8.2f\t%8.3f", $pt,$loc,format_STA($loc), $y, ProG($loc),$se_c	;
	printf "\t%8.3f\n", ProG($loc) + $se_c; 
	$cogo_pts->{$pt}{'deck'} = nearest(0.001,ProG($loc) + $se_c) ;

}


close($fh);

open (my $fh3, ">", "all_cogo_pts.yaml") 
          or die "Connot open file : $!";
print $fh3 YAML::Dump( $cogo_pts );
close ($fh3);





# lets do some testing
 say " ";
 say " ";
 if (1 == 0 ) {
 for my $loc  (21077.96, 11077.78,  11048,  11047.11,  11062.48, 11062.52 ) {
	 say " ";
	    my $y;
	    if ($loc > 11100) {$y=25.32}
		else {$y=52.05}
        say  "Sta $loc  -> ",  ( join " ", find_sec($loc) );
 		say "offset equals = $y";
 	    say el_from_left($y, find_sec($loc)) ." - ". el_from_left(0, find_sec($loc));
 		my $se_c = el_from_left($y, find_sec($loc))- el_from_left(0, find_sec($loc));
 		say  "Sta=$loc  offset= $y  super_corection= $se_c";
		printf  "ProG=%8.3f",  nearest(0.001,ProG($loc));
		say " ";
 }
}

 say " ";
 say " ";
 if (1 == 1 ) {
 for my $loc  ( 21350.24, 11350) {
	 say " ";
	    my $y;
	    if ($loc == 11350) {$y=-30.75}
		else {$y=0}
        say  "Sta $loc  -> ",  ( join " ", find_sec($loc) );
 		say "offset equals = $y";
 	    say el_from_left($y, find_sec($loc)) ." - ". el_from_left(0, find_sec($loc));
 		my $se_c = el_from_left($y, find_sec($loc))- el_from_left(0, find_sec($loc));
 		say  "Sta=$loc  offset= $y  super_corection= $se_c";
		printf  "ProG=%8.3f",  nearest(0.001,ProG($loc));
		say " ";
 }
}
# ============================================================================

sub find_sec  {
# give an independent station return a paired list of numbers
# (breaks in slope)(ft)  followed by slopes (%)
# ie    -5.17ft,  1.6ft/ft,  24ft, -1.6ft/ft
#
	my $ind_sta = shift;
#	print " in = $ind_sta ";
	for my $x ( 0 .. scalar @sta -2  ) {
#		say $sta[$x];
		if ($sta[$x] <= $ind_sta &&  $ind_sta <= $sta[$x+1] ) {
#			print "b/w $sta[$x]  and  $sta[$x+1]  Length of section= $deltaL[$x] \n";
			my $percent_in = ( $ind_sta - $sta[$x] ) / $deltaL[$x];
#			say " $percent_in  of the way ";
#			say Dumper($xs->[$x]);
#			say Dumper($xs->[$x+1]);
			#
            # find the prorated slopes and breaks
            my $back = $x;  # better names
		    my $ahead = $x+1;	
			my $s_size = scalar @{ $xs->[$back]{s} };
			#check that bk and ah have same number of slopes
            if ($s_size != scalar @{ $xs->[$ahead]{s} } ) { say "#slopes <> #slopes" }
			#loop over all slopes
			my @calc_sec;
			#return an list of offsets and slopes
			my $i;
			foreach  $i ( 0 .. ($s_size - 1)  ) {
#			  say "back slope  $i   $xs->[$back]{s}[$i]";
#			  say "ahead slope  $i   $xs->[$ahead]{s}[$i]";
			  my $delta_slope = $xs->[$ahead]{s}[$i] - $xs->[$back]{s}[$i];
			  my $calc_slope =   $xs->[$back]{s}[$i] + $percent_in * $delta_slope;
#			  say  " $i  calc_slope $calc_slope " ;
			  push @calc_sec,  ($xs->[$back]{bk}[$i] + $xs->[$ahead]{bk}[$i])  / 2.0;
			  push @calc_sec, $calc_slope;

		  }
		  #push the last bk
		  push @calc_sec,  ($xs->[$ahead]{bk}[-1] + $xs->[$ahead]{bk}[-1])  / 2.0;
		  #say join " ", @calc_sec;		  
		  #
		  #
		 #code in a special case for unit 1 if the station is b/w 110+47.11 and 110+88.88
		 #then there are two cases radial prior to 11062.50  and linear after
		 if ( $ind_sta >= 11047.11 &&  $ind_sta <= 11088.88 ) {
			 if ( $ind_sta <= 11062.50 ) {   # radial
				 # use  the legs of a right-triangle  opp, adj and hyp
				 # hyp=Radius=348
				 my $hyp= 348.0;
				 my $opp = 11079.88 - $ind_sta;
				 my $adj = sqrt( $hyp**2 -$opp**2);
				 # now we must replace the third value in the array @calc_sec with a 
				 # modified location of the crown
				 # third value is the location of the first (only) crown break
				 $calc_sec[2] = 24.8857 + $hyp - $adj ;
			 }
			 else {  #linear section 
				 $calc_sec[2] = 25.32 -  (($ind_sta - 11062.50) * 0.05005688); 
			 }
		 }

	     return @calc_sec;		

		}
	}
}

# ============================================================================

sub el_from_left {
#input an offset in (FT) and   paired list of numbers
# (breaks in slope)(ft)  followed by slopes (%)
# ie    -5.17ft,  1.6ft/ft,  24ft, -1.6ft/ft,  41.17ft
# so @_  might be  6.5,  -5.17,  1.6,  24, -1.6, 41.17
#
#  @_ should ALWAYS be even
#  one  ind_os
#  and an odd number of bks and slopes
#
#  for each section calculate a delta_el
#say join " | ", @_;

my @bks;
my @slopes;
my $ind_os = shift ;
for my $i ( 0 .. (scalar @_ / 2  - 1 )) {
	push @bks , shift;
	push @slopes , shift;
}
push @bks, shift;
#if ind_os is possitive work r to L
#if ind_os is negative  work l to r
#       work on this   need  left elevation
#

say join " ",@_  unless defined $bks[-1];

if ( $ind_os <= $bks[0]  ||  $bks[-1] <= $ind_os ) { 
	#say "\n\nerror with offset=$ind_os !!\n";
	return -1000;
    exit;   #big stop
}

my $delta_el = 0;
for my $y ( 0 .. scalar @bks - 2) {
    if ($bks[$y] <= $ind_os  &&  $ind_os <= $bks[$y+1] ) {
	      $delta_el += ( $ind_os  -  $bks[$y]  ) *  $slopes[$y] / 100.0;
		  return $delta_el;    #now we can stop
		}
		else {$delta_el += ($bks[$y+1] - $bks[$y]) *  $slopes[$y] / 100.0 }
	}
}

# ============================================================================

sub ProG{
	# the profile grade of lewis and clark expressway 
	my $x = shift @_;

	#
    # updated slopes past 133+00  oct 20, 2015
	my ( $EL_start,  @STA_PG,  @Grade_PG ) ; 
	if ($x < 20000) {
        # profile info for the mainline PRO_IM	
		$EL_start = 838.26;
		@STA_PG = qw(   11047.11  11190   11690   12500    12800   12850   13150    13300   13800   14028.69 );
		#use much better precision for the Grades
		@Grade_PG = qw( -0.0239463   -0.0239463   -0.0128      -0.0128  -0.0414    -0.0414 
		                -0.02460018  -0.02460018  -0.0050006    -0.0050006);
	} else {
        # profile info for Ramp_C	
		$EL_start = 829.14;
		@STA_PG = qw(   21045.76   21100     21340     21341.38  );
		@Grade_PG = qw( 0.022981  .022981  -0.018077  -0.018077  );
	}



	
	my $EL_temp = 0.00;
	my $EL;
	if ($x < $STA_PG[0] || $x > $STA_PG[-1]) {return "null"} 
	
	for (my $i=0; $i < scalar(@STA_PG)-1 ; $i++) {
		my $L = $STA_PG[$i+1] -  $STA_PG[$i];
        my $R = ($Grade_PG[$i+1] -  $Grade_PG[$i]) / $L;
		my $deltaX = $x - $STA_PG[$i];

		if ($x >= $STA_PG[$i] && $x <= $STA_PG[$i+1]) {
				$EL = $EL_start + $EL_temp + $Grade_PG[$i]*$deltaX + ($R*$deltaX**2.0) / 2.0;
				return $EL;
			}
			#print "loop\n";
		
		$EL_temp = $EL_temp + $Grade_PG[$i]*$L + $R*$L**2.0/2.0;
	}
}

#
# ============================================================================
#
sub format_STA {
    my $sta = nearest (0.01,shift @_);
    $sta = sprintf("%.2f", $sta); 
    return   sprintf("%s\+%s", substr($sta,0,-5), substr($sta,-5) );
    }
#
# ============================================================================
#


