#!/usr/bin/perl -w
# create a SQLite test database
# vim: set expandtab:
# vim: ts=4:softtabstop=4
use strict;
use Math::Trig;
use My::SQLite::More;  #need to figure out what and how to export
use My::SQLite::AISC_Bolts (qw( shape2row depth2row section_family  n_shear_planes 
                    n_bolts_TV sqlite_aisc_bolts angle_prying_check Fnt_prime J3_2));  
use Math::Round;
my $pi=3.141593;

my $diam_b = 0.75;
my $conn_type="angle";
my $web_t = 0.25;   #web thickness
my $Fu_angle = 36;
my $p = 3;

my $resultant;    
my $angle = 180;   # in degrees 
 
my $bolt_rows = 0.5;   #run these with 0.5, simulates 1 bolt
my $bolt_mat = "A325";
my $leg_l = 4.0;
my $leg_t = 0.75;
my $gage = 4.25;

my $inp_Fx = -40;
my $V = 0;
my $apc =  angle_prying_check(
          "inp_Fx",$inp_Fx,  
          "V",$V,  
          "web_t",$web_t,  
          "bolt_rows",$bolt_rows, 
          "leg_t",$leg_t, 
          "diam_b", $diam_b, 
          "Fu_angle", $Fu_angle, 
          "conn_type", $conn_type, 
          "gage", $gage, 
          "p", $p,
          "output",3 ,
          "debug",3
          ) ;


my $n_bolts_TV_check =  n_bolts_TV(
                          "inp_Fx",$inp_Fx,  
                          "V",$V,  
                          "diam_b", $diam_b ) ;

print "\nconn\tdiam_b\tmat\tgage\tleg_l\tFu_leg\tleg_t\tangle\tFx\tV\tn_b_ck\tAPC\n\n";
print "$conn_type\t$diam_b\t$bolt_mat\t$gage\t$leg_l\t$Fu_angle\t";
print  "$leg_t\t$angle\t";
printf "%5.2f\t%5.2f\t%5.2f\t",      $inp_Fx, $V, $n_bolts_TV_check  ;
print  "$apc\n";


if (1==0) {

my $stop = 0;
$resultant = 1;
$apc = 0.5;
$n_bolts_TV_check =0;

until ( $stop == 1) { 

    $resultant = $resultant + (1.0-$apc) * 0.2 ;       
    $inp_Fx = $resultant * cos(deg2rad($angle));
    $V = $resultant * sin(deg2rad($angle));

    $apc =  angle_prying_check(
          "inp_Fx",$inp_Fx,  
          "V",$V,  
          "web_t",$web_t,  
          "bolt_rows",$bolt_rows, 
          "leg_t",$leg_t, 
          "diam_b", $diam_b, 
          "Fu_angle", $Fu_angle, 
          "conn_type", $conn_type, 
          "gage", 5.5, 
          "p", $p,
          "output",0 ,
          "debug",0
          ) ;
      $n_bolts_TV_check =  n_bolts_TV(
                                  "inp_Fx",$inp_Fx,  
                                  "V",$V,  
                                  "diam_b", $diam_b ) ;
      if ( $n_bolts_TV_check > 0.98 ) { $stop = 1 }
      if ( $apc > 0.997) { $stop = 1 }    
}
    print "$conn_type\t$diam_b\t$bolt_mat\t$gage\t$leg_l\t$Fu_angle\t";
              print  "$leg_t\t$angle\t";
              printf "%4.2f\t%5.2f\t%5.2f\t%5.2f\t",     $resultant, $inp_Fx, $V,$n_bolts_TV_check  ;
              print  "$apc\n";
}
