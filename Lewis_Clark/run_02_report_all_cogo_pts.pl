use strict;
use Math::Trig;
use Math::Round;
use feature 'say';
use Scalar::Util qw( looks_like_number );
use YAML qw( LoadFile Load ); #LoadFile isn't exported by default
use Data::Dumper;

my ($pt) = LoadFile('./all_cogo_pts.yaml');

my $unit1c =0 ;   # 1 = true  0 = false
my  $unit1 =1 ;   # 1 = true  0 = false
my  $unit2 =0 ;   # 1 = true  0 = false
my  $unit3 =0;    # 1 = true  0 = false
my  $unit4 =0;    # 1 = true  0 = false
my  $unit5 =0;    # 1 = true  0 = false
my  $unit6 =0;    # 1 = true  0 = false
my  $unit7 =0;    # 1 = true  0 = false

#toggle for printing the point name or the information
my $print_name = 0;  # print point name or info?
#for my $i ( 10 .. 19 ) {


if ($unit1c) {
    say "";
for  my $i ( "1"  ) { #span
	for  my $k ( 0 .. 10 ) { #nth point
    print "span_" . $i . "__pt_" . "$k\t";
	for  my $j ( 1 .. 3 ) {  #girder line
		 my $beam = sprintf "G%02d%02d",  $j,$k;

		if ( $i == "1" && $k eq 0 ) {
				$beam=  sprintf "BA%02d%02d", $i,$j;
				}
		if ( $i == "1" && $k eq 10 ) {
				$beam=  sprintf "BB%02d%02d", $i+1,$j;
				}
          #say "Span_$i"."_".$j;
            if ($print_name) { print "$beam\t" }
                else {
                if (defined $pt->{$beam} ) {
                    print  "$pt->{$beam}{'sta'} \t";
                    print  "$pt->{$beam}{'offset'} \t";   
                    print  "$pt->{$beam}{'deck'} \t";
                }
            else {print " \t \t \t"}
            }
	       }
		print "\n";
	}
}	
}

if ($unit1) {
    say "";

for  my $i ( "1"  ) { #span
	for  my $k ( 0 .. 10 ) { #nth point
    print "span_" . $i . "__pt_" . "$k\t";
	for  my $j ( 5 .. 11 ) {  #girder line
		 my $beam = sprintf "G%02d%02d",  $j,$k;

		if ( $i == "1" && $k eq 0 ) {
				$beam=  sprintf "BA%02d%02d", $i,$j;
				}
		if ( $i == "1" && $k eq 10 ) {
				$beam=  sprintf "BB%02d%02d", $i+1,$j;
				}

#		say "Span_$i"."_".$j;
            if ($print_name) { print "$beam\t" }
            else {
                if (defined $pt->{$beam} ) {
                    print  "$pt->{$beam}{'f_sta'} \t";
                    print  "$pt->{$beam}{'offset'} \t";   
                    print  "$pt->{$beam}{'deck'} \t";
                }
                else {print " \t \t \t"}
            }

		}
		print "\n";
	}
}	
}

if ($unit2) {
    say "";
    for  my $i ( 2, 3 ) {  #span
        for  my $k ( 0 .. 10 ) {  #nth point
            if ( $i == 2 and $k == 10 ) {next}  # skip interior 10th point
            print "span_" . $i . "__pt_" . "$k\t";
            for  my $j ( 1 .. 9) {  #girder

                my $beam = sprintf "%1d%1d%02d", $i,$j,$k;
                if ( $i == 2 && $k eq 0 ) {
                    $beam=  sprintf "BA%02d%02d", $i,$j;
                }
                if ($i == 3 && $k eq 10 ) {
                    $beam=  sprintf "BB%02d%02d", $i+1,$j;
                }
                if ($print_name) {
                     print "$beam\t"}
                    else {
                    if (defined $pt->{$beam} ) {
                        print  "$pt->{$beam}{'sta'} \t";
                        print  "$pt->{$beam}{'offset'} \t";   
                        print  "$pt->{$beam}{'deck'} \t";
                    }
                    else {print " \t \t \t"}
                }
            }

            print "\n";
        }
    }	
}


if ($unit3) {
    say "";
    for  my $i ( 4, 5 ) {  #span
        for  my $k ( 0 .. 10 ) {  #nth point
            if ( $i == 5 && $k eq 00 ) {next}
            print "span_" . $i . "__pt_" . "$k\t";
            for  my $j ( 1 .. 6 ) {  #girder

                my $beam = sprintf "%1d%1d%02d", $i,$j,$k;

                if ($i == 5 && $k eq 10 ) {
                    $beam=  sprintf "BB%02d%02d", $i+1,$j;
                }
                
                if ($print_name) {
                     print "$beam\t"}
                    else {
                    if (defined $pt->{$beam} ) {
                        print  "$pt->{$beam}{'sta'} \t";
                        print  "$pt->{$beam}{'offset'} \t";   
                        print  "$pt->{$beam}{'deck'} \t";
                    }
                    else {print " \t \t \t"}
                }
            }

            print "\n";
        }
    }	
}


if ($unit4) {
    say "";
    for  my $i ( 6 .. 9 ) {  #span
        for  my $k ( 0 .. 10 ) {  #nth point
                if ($i >= 5 && $i <= 8 && $k eq 10) {next}
            print "span_" . $i . "__pt_" . "$k\t";
            for  my $j ( 1 .. 6 ) {  #girder

                my $beam = sprintf "%1d%1d%02d", $i,$j,$k;

                if ( $i == 6 && $k eq 0 ) {
                    $beam=  sprintf "BA%02d%02d", $i,$j;
                }
                if ($i == 9 && $k eq 10 ) {
                    $beam=  sprintf "BB%02d%02d", ($i+1),$j;
                }

                if ($print_name) {
                     print "$beam\t"}
                    else {
                    if (defined $pt->{$beam} ) {
                        print  "$pt->{$beam}{'sta'} \t";
                        print  "$pt->{$beam}{'offset'} \t";   
                        print  "$pt->{$beam}{'deck'} \t";
                    }
                    else {print " \t \t \t"}
                }
                
            }

            print "\n";
        }
    }	
}


if ($unit5) {
    say "";
    for  my $i ( 10 .. 14 ) {  #span
        for  my $k ( 0 .. 10 ) {  #nth point
            print "span_" . $i . "__pt_" . "$k\t";
            for  my $j ( 1 .. 4, 6 ) {  #girder

                my $beam = sprintf "%2d%1d%02d", $i,$j,$k;

                if ($print_name) {
                     print "$beam\t"}
                    else {
                    if (defined $pt->{$beam} ) {
                        print  "$pt->{$beam}{'sta'} \t";
                        print  "$pt->{$beam}{'offset'} \t";   
                        print  "$pt->{$beam}{'deck'} \t";
                    }
                    else {print " \t \t \t"}
                }
            }

            print "\n";
        }
    }	
}


if ($unit6) {
    say "";
    for  my $i ( 15 .. 19 ) {  #span
        for  my $k ( 0 .. 10 ) {  #nth point
            print "span_" . $i . "__pt_" . "$k\t";
            for  my $j ( 1 .. 4, 6 ) {  #girder

                my $beam = sprintf "%2d%1d%02d", $i,$j,$k;

                if ($print_name) {
                     print "$beam\t"}
                    else {
                    if (defined $pt->{$beam} ) {
                        print  "$pt->{$beam}{'sta'} \t";
                        print  "$pt->{$beam}{'offset'} \t";   
                        print  "$pt->{$beam}{'deck'} \t";
                    }
                    else {print " \t \t \t"}
                }
            }

            print "\n";
        }
    }	
}

if ($unit7) {
    say "";
    for  my $i ( 20 ) {  #span
        for  my $k ( 0 .. 10 ) {  #nth point
            print "span_" . $i . "__pt_" . "$k\t";
            for  my $j ( 1 .. 4, 6 ) {  #girder

                my $beam = sprintf "%2d%1d%02d", $i,$j,$k;

                if ($print_name) {
                     print "$beam\t"}
                    else {
                    if (defined $pt->{$beam} ) {
                        print  "$pt->{$beam}{'sta'} \t";
                        print  "$pt->{$beam}{'offset'} \t";   
                        print  "$pt->{$beam}{'deck'} \t";
                    }
                    else {print " \t \t \t"}
                }
            }

            print "\n";
        }
    }	
}
# 
