use strict;
use Math::Trig;
use Math::Round;
use feature 'say';
use Scalar::Util qw( looks_like_number );
use YAML qw( LoadFile Load ); #LoadFile isn't exported by default
use Data::Dumper;

my ($pt) = LoadFile('./all_cogo_pts.yaml');
my ($ht) = LoadFile('./top_of_concrete.yaml');




my $unit1c =0 ;   # 1 = true  0 = false
my  $unit1 =0 ;   # 1 = true  0 = false
my  $unit2 =0 ;   # 1 = true  0 = false
my  $unit3 =0;    # 1 = true  0 = false
my  $unit4 =0;    # 1 = true  0 = false
my  $unit5 =0;    # 1 = true  0 = false
my  $unit6 =0;    # 1 = true  0 = false
my  $unit7 =0;    # 1 = true  0 = false
my  $unit1_bev =0;    # 1 = true  0 = false
my  $splices =1;    # 1 = true  0 = false

#toggle for printing the point name or the information
my $print_name = 0;  # print point name or info?
#for my $i ( 10 .. 19 ) {


if ($unit1c) {
    say "";
	my $unit="1c";
for  my $i ( "1"  ) { #span
	for  my $k ( 0, 10 ) { #nth point
	my $pier = $i;   
    print "span_" . $i . "__pt_" . "$k\n";
	for  my $j ( 1 .. 3 ) {  #girder line
		 my $cogo_pt = sprintf "G%02d%02d",  $j,$k;

		if ( $i == "1" && $k eq 0 ) {
				$cogo_pt=  sprintf "BA%02d%02d", $i,$j;
				}
		if ( $i == "1" && $k eq 10 ) {
				$cogo_pt=  sprintf "BB%02d%02d", $i+1,$j;
				$pier = $i +1;
				}
          #say "Span_$i"."_".$j;
            if ($print_name) { print "$cogo_pt\t" }
                else {
					if (defined $pt->{$cogo_pt} ) {
						printline ($unit, $pier, $cogo_pt);
					}
            else {print " \t \t \t"}
            }
			print "\n";
	       }
		print "\n";
	}
}	
}

if ($unit1) {
    say "";

for  my $i ( "1"  ) { #span
	my $unit=1;
	for  my $k ( 0 .. 10 ) { #nth point
		my $pier = $i;   
		print "span_" . $i . "__pt_" . "$k\n";
		for  my $j ( 5 .. 11 ) {  #girder line
			 my $cogo_pt = sprintf "G%02d%02d",  $j,$k;

			if ( $i == "1" && $k eq 0 ) {
					$cogo_pt=  sprintf "BA%02d%02d", $i,$j;
					}
			if ( $i == "1" && $k eq 10 ) {
					$cogo_pt=  sprintf "BB%02d%02d", $i+1,$j;
					$pier = $i +1;
					}

	#		say "Span_$i"."_".$j;
				if ($print_name) { print "$cogo_pt\t" }
				else {
					if (defined $pt->{$cogo_pt} ) {
						printline ($unit, $pier, $cogo_pt);
					}
				}
				print "\n";
			}
			print "\n";
		}
	}	
}

if ($unit2) {
    say "";
	my $unit=2;
    for  my $i ( 2, 3 ) {  #span
		my $pier = $i;   
        for  my $k ( 0 , 10 ) {  #nth point
            if ( $i == 2 and $k == 10 ) {next}  # skip interior 10th point
            print "span_" . $i . "__pt_" . "$k\n";
            for  my $j ( 1 .. 9) {  #girder

                my $cogo_pt = sprintf "%1d%1d%02d", $i,$j,$k;
                if ( $i == 2 && $k eq 0 ) {
                    $cogo_pt=  sprintf "BA%02d%02d", $i,$j;
                }
                if ($i == 3 && $k eq 10 ) {
                    $cogo_pt=  sprintf "BB%02d%02d", $i+1,$j;
					$pier = $i + 1;
                }
                if ($print_name) {
                    print "$cogo_pt\t"}
                    else {
						if (defined $pt->{$cogo_pt} ) {
							printline ($unit, $pier, $cogo_pt);
						}
					}
				print "\n";
            }

            print "\n";
        }
    }	
}


if ($unit3) {
    say "";
	my $unit=3;
    for  my $i ( 4, 5 ) {  #span
		my $pier = $i;   
        for  my $k ( 0,  10 ) {  #nth point
            if ( $i == 5 && $k eq 00 ) {next}
            if ( $i == 4 && $k eq 10 ) {$pier = $i + 1}
            if ( $i == 5 && $k eq 10 ) {$pier = $i + 1}

            print "span_" . $i . "__pt_" . "$k\n";

            for  my $j ( 1 .. 6 ) {  #girder

                my $cogo_pt = sprintf "%1d%1d%02d", $i,$j,$k;


				#my $super = $ht->{'
                if ($print_name) {
                     print "$cogo_pt\t"}
                    else {
						if (defined $pt->{$cogo_pt} ) {
							printline ($unit, $pier, $cogo_pt);
						}
					}
				print "\n";
            }

            print "\n";
        }
    }	
}


if ($unit4) {
    say "";
	my $unit=4;
    for  my $i ( 6 .. 9 ) {  #span
		my $pier = $i;   
        for  my $k ( 0, 10 ) {  #nth point
                if ($i >= 5 && $i <= 8 && $k eq 10) {next}
            print "span_" . $i . "_pt_" . "$k\n";
            for  my $j ( 1 .. 6 ) {  #girder
				
				
                my $cogo_pt = sprintf "%1d%1d%02d", $i,$j,$k;

                if ( $i == 6 && $k eq 0 ) {
                    $cogo_pt=  sprintf "BA%02d%02d", $i,$j;
                }
                if ($i == 9 && $k eq 10 ) {
                    $cogo_pt=  sprintf "BB%02d%02d", ($i+1),$j;
					$pier= $i+1; # need to get to the 10th pier
                }

                if ($print_name) {
                     print "$cogo_pt\t"}
                    else {
						if (defined $pt->{$cogo_pt} ) {
							printline ($unit, $pier, $cogo_pt);
						}
					}
				print "\n";
            }

            print "\n";
        }
    }	
}

if ($unit1_bev) {
    say "";

for  my $i ( "1"  ) { #span
	my $unit=1;
	for  my $k ( 0, 1, 9, 10 ) { #nth point
		my $pier = $i;   
		print "span_" . $i . "__pt_" . "$k\n";
		for  my $j ( 5 .. 11 ) {  #girder line
			 my $cogo_pt = sprintf "G%02d%02d",  $j,$k;

			if ( $i == "1" && $k eq 0 ) {
					$cogo_pt=  sprintf "BA%02d%02d", $i,$j;
					}
			if ( $i == "1" && $k eq 10 ) {
					$cogo_pt=  sprintf "BB%02d%02d", $i+1,$j;
					$pier = $i +1;
					}

	#		say "Span_$i"."_".$j;
				if ($print_name) { print "$cogo_pt\t" }
				else {
					if (defined $pt->{$cogo_pt} ) {
						printline ($unit, $pier, $cogo_pt);
					}
				}
				print "\n";
			}
			print "\n";
		}
	}	
}
if ($splices) {
# when doing the splices there is another YAML
# file with the deflections at each of the splices
# this will go $sp_dfl,  sample of YAML below:
# show are the 6 splices at girder 8 shown as a list.
	#---
	#SP_G8:
	#  - 0.728
	#  - 0.696
	#  - 0.162
	#  - 0.022
	#  - 0.418
	#  - 0.545
	#SP_G7:
	#
my ($sp_dfl) = LoadFile('./U2_splice_deflection.YAML');
say;
say "Unit 2 splices";
printf	"    slab= %7.3f ",$ht->{2}{'slab'} ; 
printf 	"  haunch= %7.3f ",$ht->{2}{'haunch'} ;
my $unit=2;
for  my $k ( 1 .. 6 ) { #nth point
			printf 	"sp_plate= %7.3f ",$ht->{2}{"SP".$k}{'t_top_plate'}  ;
			printf  " tp_flng= %7.3f\n",$ht->{2}{"SP".$k}{'t_top_f'}  ;

	for  my $j ( 1 .. 8 ) {  #girder line
		 my $cogo_pt =  "SP".$j.$k;
		 my $u2_spl = "SP".$k;
		 my $df = $sp_dfl->{"SP_G$j"}[$k-1];
#		say "Unit $i"."_".$j;
		if (defined $pt->{$cogo_pt} ) {
			printf  "%-8s", $cogo_pt;
			printf  "%-10s", $pt->{$cogo_pt}{'f_sta'} ;
			printf  "%6.2f ",  $pt->{$cogo_pt}{'offset'} ;   
			printf  "Deck= %7.3f ",$pt->{$cogo_pt}{'deck'};
			printf  "Dfl= %7.3f ",$df;
			my $drop = (
						-$ht->{2}{'slab'} + 
						-$ht->{2}{'haunch'} +
			            $ht->{2}{"SP".$k}{'t_top_f'}  +
						$ht->{2}{"SP".$k}{'t_top_plate'} ) /12.0  +
				        $df	;
			printf  "drop=%6.2f ", $drop;
			printf  "t_steel=%6.2f ",$pt->{$cogo_pt}{'deck'}+$drop;
			
		}
		
			print "\n";
		}
		print "\n";
	}
}	



sub printline {
	my $unit = shift;
	my $pier = shift;
	my $cogo_pt = shift;
	printf  "%-8s", $cogo_pt;
	printf  "%-10s", $pt->{$cogo_pt}{'f_sta'} ;
	printf  "%6.2f ",  $pt->{$cogo_pt}{'offset'} ;   
	printf  "Deck= %7.3f ",$pt->{$cogo_pt}{'deck'};
   
	my $super = $ht->{$unit}{'slab'} + 
				$ht->{$unit}{'web'} + 
				$ht->{$unit}{'haunch'} +
				$ht->{$unit}{$pier}{'t_btm_f'};

	printf  " super= %7.3f\" ", $super;
	my $bht = eval $ht->{$unit}{$pier}{'brging_ht'} ;

	printf  "brg= %6.3f\" ", $bht ;

	printf  "TOC= %6.2f", ($pt->{$cogo_pt}{'deck'} - ($super + $bht)/12.0); 
	#printf  "  %s %s %s", $unit, $pier, $cogo_pt; 
}
