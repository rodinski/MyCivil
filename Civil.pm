package My::Civil;

use Exporter;
use strict;
use warnings;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = '0.20';
@ISA         = qw (Exporter);
#@EXPORT      = qw( ProG chk_ProG format_STA parse_ft_in 
#                   slope_camber feet2callout ftc translate 
#                   rotate c2p p2c gap_list );
@EXPORT      = qw( ftc );
@EXPORT_OK   = qw( ProG chk_ProG format_STA parse_ft_in 
                   slope_camber feet2callout ftc translate 
                   rotate c2p p2c pairgap) ;

%EXPORT_TAGS = ( all   => [ qw( ProG chk_ProG format_STA parse_ft_in 
                                slope_camber feet2callout translate 
                                rotate c2p p2c pairgaps) ],

	             civil => [ qw ( ftc parse_ft_in Pro chk_ProG format_STA slope_camber
                                 feet2callout ) ]    );

use feature  qw( say );
use Data::Dumper;
use Math::Round;




# ============================================================================
sub chk_ProG {
	my $ref_curves = shift;
	my $l_curve =  scalar  @{ $ref_curves->{'STA'} }  ;
    say "number of points = $l_curve" ; 
    my $r_s = $ref_curves->{STA};
    my $r_g = $ref_curves->{grade};
    my $r_e = $ref_curves->{elevation};
	my @TempEl ; #ref to temp elevations 
    
	for (my $i = 0 ; $i < scalar  $l_curve -1; $i++ ) {
        #say "i = $i";
        my $ip= $i+1;
        my $g1 =  $r_g->[$i];
        my $g2 =  $r_g->[$i+1];
		my $l = $r_s->[$i+1] - $r_s->[$i];
		my $r = $g2 - $g1 ;
        my $cal_d_EL = $g1 * $l /100.0 +  $r/2.0/$l*$l**2/100.0 ; 
        my $given_d_EL = $r_e->[$i+1] - $r_e->[$i];
        printf "%2d STA= %8.2f  g1= %+5.3f e1= %6.2f   e2= %6.2f g2= %+5.3f\n",
                         $i, $r_s->[$i],  $g1,$r_e->[$i],   $r_e->[$i+1], $g2;
        if ( abs( $cal_d_EL  - ($r_e->[$i+1] - $r_e->[$i] ) ) > 0.002) {
            say "";
            #say "segment $i to $ip has:";
            #printf  "given       delta_e =%7.3f\n",  $given_d_EL;
            #printf  "calculated  delta_e =%7.3f\n",  $cal_d_EL;
            #try to find the find grades that will make the elevations work
            my $sum_g = 200* $given_d_EL /$l  ;#correcting slope needed
            #say "change:  sta= grade[$ip] = " . eval($sum_g - $g1);
            printf "sta[$ip]= %8.2f  g[$ip]= %+5.3f  e[$ip]= %6.2f\n"
                  ,$r_s->[$i+1]-0.01 , eval($sum_g - $g1),$r_e->[$i+1] ;

        }
    }
    return;
}


sub ProG {
	my $known_sta = shift;
	my $ref_curves = shift;
	my $l_curve =  scalar  @{ $ref_curves->{'STA'} }  ;
	#print Dumper($ref_curves) ;
	#print "\n\n";
	#say "Station is $known_sta ";
	#say $ref_curves; 	
    my $r_s = $ref_curves->{STA};
    my $r_g = $ref_curves->{grade};
    my $r_e = $ref_curves->{elevation};
	my @TempEl ; #ref to temp elevations 
	if ( not defined $r_e->[0] ) { 
		say "No starting elevation in sub ProG";
		exit;
	}
	else {
		$TempEl[0] = $r_e->[0]; #do my own calculation of Elevtaion 
	}

	my $rate;
	my $el_1;
	my $delta_s;
	my $delta_g;
	if ( $known_sta < $r_s->[0] || $known_sta > $r_s->[-1] ) {
		say "input station out of range in sub ProG"; exit;
	}

    #loop over all 
	for (my $i = 0 ; $i < scalar  $l_curve -1; $i++ ) {
		if (not defined $r_g->[$i] or not defined $r_g->[$i+1] )  {
			say "ill formed grade array";
		}
		if (not defined $r_s->[$i] or not defined $r_s->[$i+1] )  {
			say "ill formed station array";
		}
		if ($ref_curves->{STA}[$i] > $ref_curves->{STA}[$i+1] ) { 
			say "ill formed v_curve, STA:$r_s->[$i]  is ahead of STA:$r_s->[$i+1]";
			exit;
		}
		my $l = $r_s->[$i+1] - $r_s->[$i];
		my $r = $r_g->[$i+1] - $r_g->[$i];
		#keep track of elevation i+1 as we go
		my $El_ip1 = $TempEl[$i] + $r_g->[$i]*$l/100.0 +  $r/2.0/$l*$l**2/100.0 ;
		#say "step= $i\tl=$l\tg1= $r_g->[$i]\tg2= $r_g->[$i+1]\tEl_ip1 = $El_ip1   ";
		if ( not defined $r_e->[$i+1]) {
				$TempEl[$i+1] = $El_ip1;
		}
		else { # must have been defined by the user check for size of error
			if (abs($r_e->[$i+1]-$El_ip1) > 0.02) {
			say 'Elevation correction too large at grade[' . eval($i+1) . '] location' ;
			say '$r_e->[' .eval($i+1). "] = ". $r_e->[$i+1];
			say 'vs calulated elevation  = '. $El_ip1;
			exit;
			}
			else { $TempEl[$i+1] = $r_e->[$i+1] } #use the users number
		}
		
		if ( $known_sta >= $r_s->[$i] && $known_sta<= $r_s->[$i+1] ) {
			$delta_s = $known_sta - $r_s->[$i] ;
			$delta_g = $r_g->[$i+1] - $r_g->[$i];
			my $ProG = $TempEl[$i] + $r_g->[$i]*$delta_s/100.0 +  $r/2.0/$l*$delta_s**2/100.0 ;
            my $debug = 0;
			if ( $debug   > 0 ) {
				say $r_s->[$i];
				say "  $known_sta";
				say $r_s->[$i+1];
				say "Length: $l";
				say "Delta_Sta: $delta_s";
				say "Grade_1:$r_g->[$i]";
				say "Grade_2:$r_g->[$i+1]";
				say "Delta_Grade $delta_g";
				say "  Elevation at sta $known_sta   = $ProG";
			}
			return $ProG;
		}

	}
return 1;
}

# ============================================================================
 
sub format_STA {
	my $sta = sprintf "%.2f",shift @_;
	#my $sta = nearest (0.01,shift @_);
	#$sta = sprintf("%.2f", $sta); 
	return  sprintf("%s\+%s", substr($sta,0,-5), substr($sta,-5) );
}
#==========================================================
sub parse_ft_in {
	my $s = shift @_; 
    $s =~ s/^\s+|\s+$//g ;  #trim right and left 
	my @in = split (/ +/,  $s) ;
	if (scalar @in == 4) {return nearest (0.001,$in[0] + ($in[1] + $in[2] / $in[3] )/12.0)}
	if (scalar @in == 2) {return nearest (0.001,$in[0] + ($in[1] /12.0 )) }
	return 0; 
}
#==========================================================
sub feet2callout{ 
  use Math::Round;

  my ($val,$denom) = @_;

  #if they didn't get set then use defaults;
  $denom ||= 8;  #test for non-zero set denom is not set


  my $is_neg = ($val < 0);
  $val=abs($val);
  #do some rounding but do it by whole denoms.  
  $val = nearest(1.0/$denom/12.0,$val);
  my $w_feet = int $val;
  my $inch = nearest(0.001,(($val - $w_feet) ) * 12.0);
  my $w_inch = int ($inch);
  my $f_inch = nearest(1.0/$denom,$inch-$w_inch );

  my $numerator = $f_inch*$denom;
  while ( $numerator > 1 && $numerator % 2 != 1  ) {
    $numerator /= 2; 
    $denom /= 2; 
  }
  my $ts='';
  if ($w_feet>0) {$ts="$w_feet'"};
  $ts .= " $w_inch";
  if ($numerator != 0 ) {$ts .= " $numerator/$denom"}
  $ts .= "\"";
  $ts =~ s/^\s+//;   #remove leading spaces
  if ($is_neg) { $ts = "-(".$ts.")"}
  return $ts;
}  
#--------------------------------
#
#Alias   ftc goes to feet2callout
no warnings;
*ftc = \&feet2callout;
use warnings; 
#--------------------------------
#
#
sub slope_camber{
	# input list = (sta_of_interest,  sta_brg_1,  EL_1,   sta_brg_2, EL_2,  mid_span_camber)
	# returns the elvation due to beam slope WITH camber 
	my $s = shift @_;
	my $s1 = shift @_;
	my $e1 = shift @_;
	my $s2 = shift @_;
	my $e2 = shift @_;
	my $delta_mid = shift @_;
	if ($s < $s1 || $s > $s2) {return "ng"}
	my $L = $s2 - $s1;
	my $rate = ($e2-$e1) / $L;
	my $delta_chord = ($s - $s1) * $rate;
	my $s_mid = ($s2 + $s1) / 2;
	my $delta_camber = (abs($s - $s_mid) / ($L/2.0))**2.0 * $delta_mid;
	return $e1 +  $delta_chord + ($delta_mid - $delta_camber);
}

#--------------------------------
#
sub rotate {
    use List::Util; 
    my $theta = shift;
    my $cos_t = cos $theta;
    my $sin_t = sin $theta;
    say scalar @_ % 2;
    if ( scalar @_ % 2 ) { warn "need to send rotate a cw angle and then a list of x,y pairs"}; 
    my @xy_p;
    while (@_) {
        my $x = shift;
        my $y = shift;
        my $x_p = $cos_t * $x + $sin_t * $y;
        my $y_p = -$sin_t * $x + $cos_t * $y;
        push @xy_p, $x_p, $y_p;
#        say "x:".$x_p;
#        say "y:".$y_p;

    }
    return @xy_p;
}

sub translate {
    use List::Util; 
    my $d_x = shift;
    my $d_y = shift;
    say scalar @_ % 2;
    if ( scalar @_ % 2 ) { warn "need to send translate a d_x, d_y and a list of x,y pairs"}; 
    my @xy_p;
    while (@_) {
        my $x = shift;
        my $y = shift;
        my $x_p = $x + $d_x;
        my $y_p = $y + $d_y;
        push @xy_p, $x_p, $y_p;
#        say "x:".$x_p;
#        say "y:".$y_p;
    }
    return @xy_p;
}
sub c2p {
    if ( scalar @_ % 2 ) { warn "need to send c2p pairs of x, y values in a list, while return r, theta pairs\n"};
    my @r_theta;
    while (@_) { 
        my $x = shift;
        my $y = shift;

        my $r = sqrt( $x **2 + $y **2);
        my $theta = atan2($y, $x);
        push @r_theta,   $r, $theta;
    }
    return @r_theta;
}
sub p2c {
    if ( scalar @_ % 2 ) { warn "need to send p2c pairs of r, theta values in a list, while return x, y pairs\n"};
    my @xy;
    while (@_) { 
        my $r = shift;
        my $theta = shift;
        my $x = $r * cos $theta; 
        my $y = $r * sin $theta; 
        push @xy,   $x, $y;
    }
    return @xy;
}

use List::MoreUtils;
sub pairgaps {
    my     @meshed = List::MoreUtils::mesh @_, @_;
    pop    @meshed;
    shift  @meshed;
    return @meshed;
}

    
#say join " ", rotate (45/180.0*3.1415, 10,10);
#say join " ", translate (-5, 5, 10,10, 5, 5);
#say join "  ", c2p(100, 101);
#say join "  ", c2p(101, 100);
#say join "  ", p2c (  c2p(100, 101) ) ;
1;   # modules return true to show they have loaded
