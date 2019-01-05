use strict;
use Math::Trig;
use Math::Round;
use feature 'say';
use Scalar::Util qw( looks_like_number );
use YAML qw( LoadFile Load ); #LoadFile isn't exported by default
use Data::Dumper;

my ($pt) = LoadFile('./ps_girder_elevation.yaml');

my $unit1c =0 ;   # 1 = true  0 = false
my $unit1 =0 ;   # 1 = true  0 = false
my $unit2 =0 ;   # 1 = true  0 = false
my $unit3 =1;    # 1 = true  0 = false
my $unit4 =0;    # 1 = true  0 = false
my $unit5 =0;    # 1 = true  0 = false
my $unit6 =0;    # 1 = true  0 = false
my $unit7 =0;    # 1 = true  0 = false
#for my $i ( 10 .. 19 ) {

if ($unit1c) {
for  my $i ( "G" ) {
	for  my $k ( "00" .. "10" ) {
    print "span_U1__pt_" . "$k\t";
	for  my $j  ("01","02","03") {
		 my $beam = $i.$j;
#		say "Span_$i"."_".$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
	}
}	

}
if ($unit1) {
for  my $i ( "G" ) {
	for  my $k ( "00" .. "10" ) {
    print "span_U1__pt_" . "$k\t";
	for  my $j  ("05","06","07","08","09","10","11") {
		 my $beam = $i.$j;
#		say "Span_$i"."_".$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
	}
}	
}

if ($unit2) {

for  my $i ( "02", "03" ) {


	for  my $k ( 0 .. 9 ) {
    print "span_" . $i . "__pt_" . "$k\t";
	for  my $j ( 1 .. 8 ) {
		 my $beam = $i.$j;
#		say "Span_$i"."_".$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
	}
}	
}
if (1==0) {
	for  my $i ("04", "05") {  #span
		for  my $k ( 0 .. 10 ) { # point
			print "span_n" . $i . "_pt_". "$k  ";
			for my $j ( 1 .. 6 ) {  #grider
			 my $call =	sprintf "%1d%1d%02d",$i,$j,$k ;
				my $jj =$j;

				#deal with three bearing options
				if ( $i == "04" && $k eq 0 ) {
					$call=  sprintf "BA%02d%02d", $i,$j;
				}
				if ($i == "05" && $k eq 10 ) {
					$call=  sprintf "BB%02d%02d", $i,$j;
				}
				if ( $i == "05" && $k eq 00
						   ||
					 $i == "04" && $k eq 10 	) {
					$call=  sprintf "5%1d00", $j;
				}
				#print " $call ";
		  my $beam = $i.$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
			}
			#say "";
		}
			#say "";
	}
if ($unit3) {
	for  my $i ( "04", "05" ) {
		for  my $k ( 0 .. 10 ) {
		print "span_" . $i . "__pt_" . "$k\t";
		for  my $j ( 0 .. 6 ) {

			 my $beam = $i.$j;
			if ($i == 4 && $k == 10) {$beam = "05".$j;  $k =0}
	#		say "Span_$i"."_".$j;
			  if (defined $pt->{$beam}{$k} ) {
			  print  "$pt->{$beam}{$k}{'sta'} \t";
			  print  "$pt->{$beam}{$k}{'offset'} \t";   
			  print  "$pt->{$beam}{$k}{'deck'} \t";
			   }
			   else {print " \t \t \t"}
			}
			print "\n";
		}
	}	
}





if ($unit4) {
for  my $i ( "06", "07" , "08", "09") {
	for  my $k ( 0 .. 9 ) {
    print "span_" . $i . "__pt_" . "$k\t";
	for  my $j ( 1 .. 6 ) {
		 my $beam = $i.$j;
#		say "Span_$i"."_".$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
	}
}	
}

if ($unit5) {
for  my $i ( 10 .. 14 ) {
	for  my $k ( 0 .. 10 ) {
    print "span_" . $i . "__pt_" . "$k\t";
#rmh cogo stuff mislabeled girder 5 as 6
	for  my $j ( 1 .. 4, 6 ) {
		 my $beam = $i.$j;
#		say "Span_$i"."_".$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
	}
}	
}


if ($unit6) {
for  my $i ( 15 .. 19 ) {
	for  my $k ( 0 .. 10 ) {
    print "span_" . $i . "__pt_" . "$k\t";
#rmh cogo stuff mislabeled girder 5 as 6
	for  my $j ( 1 .. 4, 6 ) {  
		 my $beam = $i.$j;
#		say "Span_$i"."_".$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
	}
}	
}
if ($unit7) {
for  my $i ( 20 ) {
	for  my $k ( 0 .. 10 ) {
    print "span_" . $i . "__pt_" . "$k\t";
#rmh cogo stuff mislabeled girder 5 as 6
	for  my $j ( 1 .. 6 ) {  
		 my $beam = $i.$j;
#		say "Span_$i"."_".$j;
          if (defined $pt->{$beam}{$k} ) {
		  print  "$pt->{$beam}{$k}{'sta'} \t";
		  print  "$pt->{$beam}{$k}{'offset'} \t";   
          print  "$pt->{$beam}{$k}{'deck'} \t";
	       }
		   else {print " \t \t \t"}
		}
		print "\n";
	}
}	
}
