package My::SQLite::AISC_Bolts;
# vim: set expandtab:
# vim: ts=4:softtabstop=4
our $VERSION = '0.01';
use 5.008008;
use strict;
use warnings;
require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw( n_bolt_v Fnt_prime section_family weld_16th
        shape2row depth2row J3_2 n_shear_planes n_bolts_TV angle_prying_check ) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(sqlite_aisc_bolts);
use DBD::SQLite 1.27;  #minimum with $dbh->sqlite_create_function
use DBI         1.609; #minimum with $dbh->sqlite_create_function
use Carp;
use Math::Round;
our $pi = 3.14159;  #global 

#---------------------------------------------
sub sqlite_aisc_bolts
{
  my $dbh=shift();  #needs to be passed an active database handle 
  
  $dbh->sqlite_create_function( 'shape2row', 1, sub { shape2row($_[0])   } );
  $dbh->sqlite_create_function( 'J3_2',      2, sub { J3_2($_[0],$_[1])   } );
  $dbh->sqlite_create_function( 'Fnt_prime',-1, sub { Fnt_prime(@_)       } );
  $dbh->sqlite_create_function( 'n_bolts_TV',  -1, sub { n_bolts_TV(@_)         } );
  $dbh->sqlite_create_function( 'angle_prying_check', -1, sub { angle_prying_check(@_) } );
}
1;


#---------------------------------------------
sub section_family {
    # call with any single string 
    my $str;
    # strip the last characters after the shape type and depth are defined
    # substituting everything after the first x or X.   ie wt12x99 -> WT12  
    ($str = $_[0]) =~ s/x.*$//i;
    return uc $str;  # make it uppper case
 } # endof section_family  

#---------------------------------------------
sub shape2row {  
    # use the text to find the depth
    # then calls  depth2row to get the minimum number of bolt rows
    # the we will speciy. 

    my $str;
    # valid know depths
    # W M S HP L LL  WT MT ST C MC  2L   and allow lower case
    # Have coded in a more general case.
   ($str = $_[0]) =~ s/^[[:alpha:]]+(\d+).*$/$1/; # Use a regular expression 
   # print "\t$str\t";
   # to strip out the first run of digits AFTER the first alpha characters
   # hyphens aren't included in the alpha set. 
   if ($str !~ /^\d+$/) {$str = 6} #if the previous regex did not produce 
   # a number then set the depth to 4 inches. This ensures that the next call
   # gets a digi.  Good for sections like "PG-3"and not text.

   return depth2row($str);  #call another sub to get the rows
 }  #end of shape2row

#---------------------------------------------
sub depth2row  {
# starts with a depth in inches and returns the minimum number of rows of bolts
# that will be specified.
    my $d; 
    $d = $_[0];
    my @depth_limit = qw(6 12 16 21 24 27 30 44);
    my @row_list =    qw(1  2  3  4  5  6  7  8);

    foreach my $i (0..7) {
    if ($d <= $depth_limit[$i])  {return $row_list[$i];}
    }
    return 1;
}  #end of depth2row

#---------------------------------------------
sub  J3_2 {
    #need "[a325,a490,a307]", "[x,n]"
    #returns two member array   FnT FnV
    my $material = shift;
    my $thread  = shift;
    my $FnV = 1.0; my $FnT = 1.0;  #set them very low by default
    #set thru the bolt types:
    if (uc $material eq "A325") 
      {$FnV = 48.0;
      $FnT = 90;
      if (uc $thread eq "X") {$FnV = 60.0} };
    if (uc $material eq "A490") 
      {$FnV = 60.0;
       $FnT = 113;
      if (uc $thread eq "X") {$FnV = 75.0} };
    if (uc $material eq "A307") 
      {$FnV = 24.0;
      $FnT = 45.0; }
   #print  "J3_2 returns :" . $FnT . "  " . $FnV . "\n";
    return ($FnT, $FnV);
}  #end of J3_2

#---------------------------------------------

sub weld_16th   
# returns the size of fillet weld needed in  1/16 of an inch
#  assumes E70 electrode with and allowable strength of
#  928 lbs per 1/16" per inch of weld
#  see below for defaults. 
#  Weld length based on number of bolt_rows
{
  my %defaults = qw(
    inp_resultant       undef
           inp_Fx       undef
                V       undef
        bolt_rows       1
                p       3.0
    end_edge_dist       1.5
            debug       0 
     n_sides_of_web     2
    );

  my %a = (%defaults, @_);
  foreach (keys %a) { 
    croak ('Unknown Arguments - ',$_) 
    unless exists $defaults{$_}};

  if ($a{debug} != 0) {
    print "Fnt: ";
    foreach my $key (keys %a) {  
    print $key, '=', $a{$key}, "| ";
    }
    print "\n";
  }
  
  if ( $a{inp_Fx} ne "undef" && $a{V} ne "undef" ) {
       # calc a resultant if inp_Fx and V are defined
       $a{inp_resultant} = sqrt ( $a{inp_Fx} ** 2  + $a{V} ** 2) 
  }
  my $weld_l = (($a{bolt_rows} - 1 ) * $a{p} + 2 * $a{end_edge_dist}) * $a{n_sides_of_web};
  if ($a{debug} != 0) {
    print "weld_l=$weld_l| inp_resultant=$a{inp_resultant}\n";
  }
  return nearest( 0.1, $a{inp_resultant} / ( $weld_l * 0.928 ) ) ;
}


#---------------------------------------------
   
#call w/  Fnt_prime("V",10.602, "debug",1, "t_type", "X")
#likely only called by B in angle_prying_check
#Fnt_prime returns the allowable tension stress for
#a given shear in kips.  If the shear is greater than the shear
#capacity of the bolt.  A warning is printed and the result passed
#out is -0.01.
#diam_b =0.75 and t_type="N" is assumed.
#
##returns allowable Tension stress (ksi) 
sub Fnt_prime  {
  my %defaults = qw(
    bolt_mat A325
    diam_b   0.75
    t_type   N
    V        undef
    omega    2.0
    debug    0
    );
  my %a = (%defaults, @_);
  foreach (keys %a) { 
    croak ('Unknown Arguments - ',$_) 
    unless exists $defaults{$_}};
 
  if ($a{debug} != 0) {
    print "Fnt: ";
    foreach my $key (keys %a) {  
    print $key, '=', $a{$key}, "| ";
    }
    print "\n";
  }
    my $V = $a{V};
    my ($Fnt,$Fnv) = J3_2($a{bolt_mat}, $a{t_type});
    my $area = $pi*$a{diam_b}**2/4.0;
    $V = abs($V);
    my $fv = $V/$area;
    if  ($fv > $Fnv/$a{omega}) { return -0.001;}  #return something small but not zero 
    my $Fnt_prime = 1.3*$Fnt-$a{omega}*$Fnt/$Fnv*$V/$area;
    if  ($Fnt_prime > $Fnt) {$Fnt_prime = $Fnt;}
    if ($a{debug} > 1) {
    print "V=$V  Fnt=$Fnt  Fnv=$Fnv  area=".nearest(0.001,$area)."  fv=".nearest(0.001,$fv);
    print "  Fnt_p/omega=" . nearest(0.01,$Fnt_prime) . " / $a{omega}";
        print "  T_force=" . nearest(0.01, $Fnt_prime/$a{omega}*$area) . "\n";
    }
    return  $Fnt_prime/$a{omega};  #ksi
}  # end of sub Fnt_prime


#---------------------------------------------
sub n_shear_planes {
    # call with ("V", #,        "diam_b", $   . . . )
    # function returns the exact number of shear planes needed
    # do a lookup in table (J3-3b)
    my %defaults = qw(
           V   undef
    bolt_mat   A325 
      t_type   N 
      diam_b   0.75
       omega   2.0
         rnd   0.01
       debug   0  
       );
    # load the defaults then override with particulars that 
    # are passed to this function 
    
    my %inp = (%defaults, @_);
    foreach (keys %inp) { 
    croak ('Unknown Arguments - ',$_) 
    unless exists $defaults{$_}};
    # print debuging if asked
    if ($inp{debug} != 0) {
        foreach my $key (keys %inp) {  
            print $key, '=', $inp{$key}, "| ";
        }
    print "\n";
    }
    # start the calculations of shear planes needed 
    my $diam_b = $inp{diam_b};
    my $omega = $inp{omega};
    my $rnd = $inp{rnd}; 
    my $area_b = $pi *$diam_b**2/4.0 ;
    my ($FnT,$FnV) = J3_2($inp{bolt_mat},$inp{t_type});
    my $V = $inp{V};
    return nearest($rnd,($V*$omega)/($FnV*$area_b))
}

#---------------------------------------------
sub n_bolts_TV {
    # call with ("inp_Fx", #  ,"V", #     then any additional options)
    # function returns the exact number of bolts needed due to axial and shear
    # note that  inp_Fx follow the RISA convension of negtive for tension possitive for compression
    # the default area_b is for 3/4 inch diam
    # only need to deal with abs(V) and don't allow V to be zero 
    # this eliminates a div by 0.0  error
    my %defaults = qw(
     inp_Fx   undef
          V   undef
   bolt_mat   A325 
     t_type   N 
     diam_b   0.75
      omega   2.0
        rnd   0.01
      debug   0  
      );
    my %inp = (%defaults, @_);
    foreach (keys %inp) { 
    croak ('Unknown Arguments - ',$_) 
    unless exists $defaults{$_}};
    # now start calculations of bolts needed
    my $diam_b = $inp{diam_b};
    my $omega = $inp{omega};
    my $rnd = $inp{rnd}; 
    my $area_b = $pi *$diam_b**2/4.0 ;
    my ($FnT,$FnV) = J3_2($inp{bolt_mat},$inp{t_type});
    my $T = $inp{inp_Fx};
    my $V = $inp{V};

    # print out debuging information if requested
    if ($inp{debug} != 0) {
        print "inp_Fx =".nearest(0.01,$inp{inp_Fx})."| V=".nearest(0.01,$inp{V})."| ";
        foreach my $key (keys %inp) {  
            print $key, '=', $inp{$key}, "| ";
    	}
    print "\n";
    }

    # continue with calculaitons
    # now adjust T and V so they are easier to deal with
    $V = abs($V);  #only possitive V
    if ($V<0.01) {$V = 0.10}
    # check compression case if so return only as function of shear  
    # remember RISA inp_Fx  +=compression  and -=tension
    # we want to call the function with inp_Fx
    # so if it is compression just calc n_bolts_TV as a function
    # of shear only and exit.
    if ($T > 0.0) {
    if ($inp{debug} != 0 ){print "| compression "; }
    return nearest($rnd,($V*$omega)/($FnV*$area_b))}

    #now that we have checked for compression the sign of T can be
    #changed so we only have to deal with possitive numbers
    $T = abs($T);
    my $ratio = $T/$V;

    # check three cases of   T/V:
    # we have already forced T>0.0 and V != 0.0
    # tension control, combinded control, shear control
    my $answer;
    if ($T/$V > $FnT/($FnV*0.3)) {
     $answer =  $T*$omega/($FnT*$area_b);
     
     if ($inp{debug} > 0) {
         $FnT = nearest(0.1,$FnT);
         print "T  ctr| $FnT / $omega |";}

      } elsif  ($T/$V >  0.3*$FnT/$FnV ) { 
      my $fvi = 1.3*$FnT/$omega / (($FnT/$FnV) + ($T/$V));
      $answer =  $V/($fvi*$area_b);
     if ($inp{debug} > 0) {
         $fvi = nearest (0.1,$fvi);
         print "TV ctr| $fvi / $omega |";}

      } else {
      $answer =  $V*$omega/($FnV*$area_b);
     if ($inp{debug} > 0) {
         $FnV = nearest(0.1, $FnV); 
         print " V ctrl $FnV / $omega |";}

      }
      return nearest($rnd,$answer);
} # end of n_bolts_TV


#---------------------------------------------
sub angle_prying_check {
    #    NOTE NEED TO  CHECK FOR TOO MUCH SHEAR OR TOO MUCH FX
    #    EARLY ON   REMOVE THIS NOTE ONECE DONE!!!!!  
    #    
    #
#  called with   "V",##,"inp_Fx",##, "ops"  $option_string
#  leg g t dia FnT Fu  web_t  p 3.0 t_type debug
#  might need add a option for the output needed
#
#  be careful when the table has a column named inp_Fx or V
#  thise will need to be called with option  like 'inp_Fx' or 'V'

 my %defaults = qw(
      inp_Fx      undef
           V      undef
       leg_l     5.0
        gage     5.5
       leg_t     0.375
      diam_b     0.75
    Fu_angle     58.0
       web_t      0.25
           p      3.0
      t_type      N
       debug      0
   bolt_rows      1
   bolt_mat       A325
   conn_type      ANGLE
      output      0
         );
    my %a = (%defaults, @_);  #creat a hash of all the defaults %a 
    foreach (keys %a) { 
        croak ('Unknown Arguments - ',$_) 
    unless exists $defaults{$_}};
    
    if ($a{debug} != 0) {    #overwrite the defaults with and called options 
        print "prying_angle_check input: ";
        my $count = 0;
        foreach my $key (sort(keys %a)) {  
            print $key, '=', $a{$key}, "| ";
            $count++;
            if ( $count % 8 == 0 ) {
                print "\n                          ";
            }
        }
        print "\n";
    }

    my ($leg,$g,$t,$diam_b,$area_b,$V,$b,$a,$p_prime,$a_p1,$a_p2,$FnT_p);
    my ($web_t,$p,$a_prime,$b_prime,$rho,$B,$d_prime,$Q,$T, $V_b);

   
    # assume no prying and check if there are enough bolts 
    #
    my $boltsneeded =  n_bolts_TV( "inp_Fx",     $a{inp_Fx}
                                    , "V",        $a{V}
                                    , "bolt_mat", $a{bolt_mat}
                                    , "t_type",   $a{t_type}
                                    , "diam_b",   $a{diam_b} ) ;
    if ( $boltsneeded > ( $a{bolt_rows} * 2 ) ) { return 11 }
   
    # get V back to just shear per bolt
    $V_b=$a{V}/ ($a{bolt_rows} *2.0);    #always 2 bolts per row, V is halved
    $T=$a{inp_Fx}/ ($a{bolt_rows} *2.0);
    #check if bolts get sheared off.
    $diam_b = $a{diam_b};
    $area_b = $a{diam_b}**2 * $pi / 4.0;
   



    $FnT_p = Fnt_prime("V",$V_b, "diam_b", $a{diam_b}, "bolt_mat",$a{bolt_mat},  "t_type",$a{t_type}) ;
    $B = $FnT_p * $area_b;  
    if ($B <= 0) { return 10} #too much shear


    # check for tension (only neg values)
    # if compression (or low tension say 200 #) and we already checked the bolts for shear 
    # continue on with a very low Tension
    # return tmin/t = 0.1 otherwise only deal with abs()
    if ($T >= -0.20) { 
        if ($a{debug}>0) {print "compression, exit with a t/t_min=10\n"}
        return 0.10;
    } 
    else {$T = abs($T);}

    # see AISC_13th  pg 9-10 "Prying Action"
    # basically check if t>t_min (ie t_min= "t req'd to ensure an acceptable 
    # combination of fitting strength and stiffness and bolt strength"
    # return  t_min / t     

    my ($b_f, $delta, $beta,$t_min,$t_c,$alpha,$q);
    $b_f = $a{leg_l}*2 + $a{web_t};
    $b = ($a{gage} - $a{web_t})/2.0 - $a{leg_t}/2.0;  #treated as a double angle see Fig 9.4b pg 9-10
    $a = $a{leg_l}-$a{leg_t}/2.0 - $b;

    if ( uc $a{conn_type} ne "ANGLE") {  
        # if conn_type is not ANGLE it must be a tee; reset b_f,b,a
        # if it is a tee then leg_l is no longer used 
        # b_f is only a function of gage and edge dist
        $b_f = $a{gage}  + 2*1.5;
        $b = ($a{gage} - $a{web_t})/2.0 ;   
        $a = $b_f/2.0  - $a{web_t}/2.0 - $b ;
        }



    $b_prime = $b - $diam_b/2.0 ;
       $a_p1 = $a + $diam_b/2.0 ;
       $a_p2 = 1.25*$b+$diam_b/2.0 ;
    if ( $a_p1 < $a_p2 ) {$a_prime = $a_p1;} 
    else {$a_prime = $a_p2;}
    if ( $a_prime <= $diam_b/2.0 ) {print "error leg too short\n"; return 11.0;}

    $rho = $b_prime/$a_prime ;
    $d_prime = $diam_b + 1.0/16.0; #for std holes
    $delta = 1.0 - $d_prime/$a{p} ;
    $beta = 1.0/$rho*($B / $T -1.0) ;


    # Note that there are two equations for calculating alpha_prime
    # this code will use alpha_prime_1 and alpha_prime_2
    #
    my $alpha_prime_1;
      if ($beta >= 1.0) {$alpha_prime_1 = 1.0 } 
    else {$alpha_prime_1 = 1.0/$delta*($beta/(1.0-$beta))}
      if ($alpha_prime_1 > 1.0) { $alpha_prime_1 = 1.0} ;

    $t_min = sqrt(6.66*$T*$b_prime/($a{p}*$a{Fu_angle}*(1.0+$delta*$alpha_prime_1)));
    # this is the "thickness required to ensure an acceptale combinaiton of 
    # fitting strength and stiffness and bolt strength"  
    #
    # calc of alpha_prime from the top of 9-13  
    if (6.66*$B*$b_prime/($a{p}*$a{Fu_angle}) < 0 ) {
        print  "B $B    b_prime $b_prime  p=$a{p}    Fu_angle=$a{Fu_angle} \n";
    }
    $t_c = sqrt(6.66*$B*$b_prime/($a{p}*$a{Fu_angle}));  # 14thEd Eq=9-30b
    #if ($a{leg_t} > $t_c) { print "no prying at _this_ loading $B per bolt" };


    my $alpha_prime_2;  #note this is not the same as the privious alpha_prime 
    # this value is needed to calculate Q and then T_avail and then Fx_avail
    $alpha_prime_2 = 1.0 /( $delta * (1+$rho) ) *  ( ($t_c/$a{leg_t})**2    - 1 ) ; #14thEd 9-35
    if ($alpha_prime_2 <= 0) {$Q =1.00}  # Eq 9-32
    elsif ( 0 < $alpha_prime_2 && $alpha_prime_2 < 1.0 ){ 
            $Q= ($a{leg_t}/$t_c)**2 * (1+$delta*$alpha_prime_2); } #Eq 9-33
    else {$Q = ($a{leg_t}/$t_c)**2 * (1+$delta);}  #Eq 9-34

    #
        # t/t_min has already been calced alpha is only needed to calc q
    # this is not necessary and only done for info
    $alpha = 1.0/$delta*($T/$B*($t_c/$a{leg_t})*($t_c/$a{leg_t})-1.0);
    if  ($alpha < 0.0 ) {$alpha = 0.0}
    if  ($alpha > 1.0 ) {$alpha = 1.0}
    if ($a{leg_t} > $t_min) {   $q = $B*$delta*$alpha*$rho*$a{leg_t}/$t_c*$a{leg_t}/$t_c }

    my $T_avail = $B*$Q;
    my $Fx_avail = -$T_avail *  $a{bolt_rows}*2; #remember RISA tension is negative


    if ($a{output} > 0) {
        printf  "t=\t%.3f\t", $a{leg_t};
        printf  "t_min=\t%.3f\t", $t_min;
        printf  "t_c=\t%.3f\t", $t_c;
            printf "t_min/t=\t%.3f", $t_min/$a{leg_t};
        print  "\t";
        }

    if ($a{output} > 1) {
        printf  "V_b=\t%.1f\t", $V_b;
        printf  "T_b=\t%.1f\t", $T;
        printf  "B=\t%.1f\t", $B;
        printf  "alpha_prime_2=\t%.2f\t", $alpha_prime_2;
        printf  "Q=\t%.2f", $Q;
        printf  "\t";
        }

    if ($a{debug} > 1) {
        print "\n\n";
        printf "|T_b| = %5.3f (k)\t",  $T;
        printf "V_b = %5.3f (k)\t",  $V_b;
        printf "diam_b = %4.2f\t",  $diam_b ;
        printf "p = %4.2f\t",  $a{p};
        printf "leg = %3.1f\n",  $a{leg_l} ;
        printf "gage = %3.1f\t",  $a{gage};
        #note $a has nothing to do with $a{?}
        printf "b_f = %5.3f\t",  $b_f;
        printf "b = %5.3f\t",  $b;
        printf "b_prime = %5.3f\t",  $b_prime ;
        printf "a = %5.3f\n",  $a;
        printf "a_prime = %5.3f\t",  $a_prime;
        printf "rho = %5.3f\t",  $rho;
        printf "t_c = %5.3f\t",  $t_c;
        printf "alpha_prime_1= %5.3f\t",  $alpha_prime_1;
        printf "alpha_prime_2= %5.3f\n",  $alpha_prime_2;
        printf "Q = %5.3f \t",  $Q ;
        printf "B of bolt = %5.3f\t",  $B ;
        if ( defined $q  ) {
            printf "q  = %5.3f (k)\t",  $q ;
        }
        print  "\n";
        if ($a{debug} > 2) {
            printf "dprime = %5.3f\t",  $d_prime;
            printf "delta = %5.3f\t",  $delta;
            printf "beta = %5.3f\t",  $beta;
            printf "Fu_angle = %5.1f\n",  $a{Fu_angle};
            printf "t = %5.3f\t",  $a{leg_t} ;
            printf "t_min = %5.3f\t",  $t_min;
            printf "t_c = %5.3f\t",  $t_c;
            printf "t_min/t = %5.3f\n",  $t_min / $a{leg_t};
        }
    } #end of angle_prying_check
return nearest(0.001,$t_min/$a{leg_t});
}   
#used to test if it is working
#angle_prying_check( "V", .2,"inp_Fx", -5 ,"debug", 1, "output", 1);
=head1 NAME

SQLite::More - Add more SQL functions to SQLite in Perl - some of those found in Oracle and others

=head1 DESCRIPTION

SQLite does not have all the SQL functions that Oracle and other RDBMSs have.
And complitated function needed for connection design

Using C<SQLite::AISC_Bolts> makes more of those functions.

SQLite::More uses the class function C<sqlite_create_function()> of
L<DBD::SQLite>, which is available from DBD::SQLite version 1.27
released 23. nov. 2009.


Normal row functions:

 sql_nbv(tension, shear)     returns the number of bolts needed to resist the resultant force
 Fnt_prime()
 depth2row(depth_of_member) returns the min number of row for a given member depth
 angle_prying_check("inp_Fx",##,   "V",##)    returns the t_min/t of a clip angle or
 end plate "tee" in prying.  The lower the result the more conservative.  
 Greater than 1.0 doesn't meet the code.

 J3_2 returns the capacity from the secion J table

