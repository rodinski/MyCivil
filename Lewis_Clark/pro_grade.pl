use strict;
use Math::Trig;
use Math::Round;
use feature qw ( say );

our $EL_start = 838.26;

say  ProG(11483.44);
my @bents = qw (11047.11  11108.44  11483.44  11858.44  11968.44
              	12098.44  12268.44  12528.44  12763.44  12953.44
			   	13058.44  13153.44  13273.44  13363.44  13458.44
			  	13568.44  13678.44  13788.44  13898.44  13998.44  
				14028.69 );


for my $s (@bents) {
  say "$s   " . nearest(0.01, ProG($s));
}


my $s = 11342.38;
say "\n\n$s   " . nearest(0.01, ProG($s));



say "\n\n$s   " . nearest(0.01, ProG(21347.10));
say "\n\n$s   " . nearest(0.01, ProG(21347.48));
say "\n\n$s   " . nearest(0.01, ProG(21348.57));


$s = 21347.10;
say "\n\n$s   " . nearest(0.01, ProG($s));
$s = 21347.48;
say "\n\n$s   " . nearest(0.01, ProG($s));
$s = 21348.57;
say "\n\n$s   " . nearest(0.01, ProG($s));



sub ProG{
	my $x = shift @_;
	#
    # updated slopes past 133+00  oct 20, 2015
	my @STA_PG = qw(   11047.11  11190   11690   12500    12800   12850   13150    13300   13800   14028.69 );
	my @Grade_PG = qw( -0.0239  -0.0239  -0.0128 -0.0128  -0.0414 -0.0414 -0.0246  -0.0246  -0.005    -0.005);

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
