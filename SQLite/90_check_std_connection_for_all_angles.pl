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

my $diam_b = 0.875;
my $conn_type="tee";
my $web_t = 0.25;   #web thickness
my $Fu_angle = 65;
my $p = 3;

my $resultant;    
my $angle = 150;   # in degrees 
 
my $bolt_rows = 0.5;   #run these with 0.5, simulates 1 bolt
my $bolt_mat = "A325";
my $leg_l = 5.0;
my $gage = 5.5;
my $apc;
my $n_bolts_TV_check;

my $inp_Fx;
my $V;

#, 1/2, 5/8, 3/4


foreach $gage (5.5, 7.5) {
    if ($gage == 5.5) {$leg_l = 4.0};
    if ($gage == 7.5) {$leg_l = 5.0};

foreach $diam_b ( 0.825, 1.125  ) {
    if ($diam_b ==0.825) {$bolt_mat="A325"};
    if ($diam_b ==1.125) {$bolt_mat="A490"};
    
#print "\nconn_type = $conn_type\ndiam_bolt = $diam_b\nFu_angle = $Fu_angle\n";
#print "bolt_rows = $bolt_rows  -> One Bolt\nweb_t = $web_t\n";
#print "\tleg_t\tangle\tR\tFx\tV\tn_bolts_TV\tt_min/t";

    foreach  my $leg_t (  0.375, 0.500, 0.625, 0.750, 0.825, 1.0, 1.125, 1.25, 1.375, 1.5) {  #loop on each line
#    print "\n";
#    foreach  my $angle ( 90, 100, 110, 120, 130, 140, 150, 160, 170,  180 ) {
    for  (my $angle = 90; $angle<=180; $angle += 10 ) {
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
          print  "\t$leg_t\t$angle\t";
          printf "%4.2f\t%5.2f\t%5.2f\t%5.2f\t",     $resultant, $inp_Fx, $V,$n_bolts_TV_check  ;
          print  "$apc\n ";
        }
    }
}
}
