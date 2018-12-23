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

my $filename="./yz_sta_offset_el.txt";

open (my $fh, "<", $filename) 
          or die "Connot open file : $!";

my $girder;  #a reference to a hash of hashes
# starting with girder number in the form of
# 124 = ahead of bent 12, 4th gider
say "point\tSTA\tSTA\toffset\tProG\tsuper\tTODeck";
while ( <$fh> ) {

if ( $_ =~/^\#/ ) { next }	#comment line
	
my $loc;
my $offset;
my $yz_el;
	chomp;

	my @line = split("\t",$_) ; #read an cogo INVERSE line
	$loc  =  $line[0];
	$offset  =  $line[1];
    $yz_el = $line[2]; 
    
	my $rmh_PG= ProG($loc);
	my $se_c = el_from_left($offset, find_sec($loc))- el_from_left(0, find_sec($loc));
	my $rmh_el = $rmh_PG+$se_c; 
	my $diff = $rmh_el-$yz_el;
	
#
#
    if ($loc > 11108.43  ) {  #only past bent 2
		if ($loc < 11333.5 && $offset < -14 ) { next }  #skip Ramp_C
#    printf "%6d\t%8.2f\t%8.2f\t%8.2f\t%8.3f", $pt,$loc, $y, ProG($loc),$se_c	;
    if (abs($diff) > 0.005 ) {
		printf "%8.2f\t%s\t%8.2f\t%8.3f\t", $loc, format_STA($loc), $offset, $yz_el	;
		printf "\t%8.3f\t%8.3f\n",$rmh_el, $diff  ; 
	}
}

}
if (0) {  #print PC and PT Elevations
	for my $loc ( qw (   11047.11  11190   11690   12500    12800   12850   13150    13300   13800   14028.69 ) ) {
	printf "%s\t%8.3f\n", format_STA($loc), ProG($loc);
}
}

close($fh);


if (0) {

open (my $fh2, ">", "ps_girder_elevation.yaml") 
          or die "Connot open file : $!";
print $fh2 YAML::Dump( $girder );
close ($fh2);
DumpFile('ps_girder_elevation.yaml',$girder);
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
