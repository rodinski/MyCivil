package My::Staad;

use Exporter;
use strict;
use warnings;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION     = '0.20';
@ISA         = qw (Exporter);
@EXPORT      = qw( list2desc mlinestaad getColumn slurp_std 
                   joint_coordinates member_incidences);
@EXPORT_OK   = qw(  list2desc mlinestaad getColumn  slurp_std  
                    joint_coordinates member_incidences);
%EXPORT_TAGS = ( all   => [ qw( &list2desc &mlinestaad &getColumn  
                           &slurp_std &joint_coordinates &member_incidences) ]);
use feature  qw( say );
use Data::Dumper;

my %hash;
$hash{debug}=0;

# ============================================================================
sub list2desc {
#input to list2desc is a list

my @n = @_;  #make a copy
say "\n" if $hash{debug};

#print join " ",@n, "\n";
my $s_current_line=0;
my $start = $n[0];

say "scalar: " . scalar @n if $hash{debug};
say "last: " . scalar @n -2  if $hash{debug};
say  "$n[0] $n[1]  $n[-3]  $n[-2]  $n[-1] \n" if $hash{debug};

my $s = sprintf "%d ",$n[0];  #sprint the first member
# loop over all the gaps between members
for my $i ( 1 .. (scalar @n - 2 )  ) {
    # 0=false
    my $bk = !($n[$i] - $n[$i-1] -1);
    my $ah = !($n[$i+1] - $n[$i] -1);
    if (!$bk) { $start =  $n[$i]; $s.=sprintf "%d ",$n[$i] };
    if ($bk && $ah) {
        if ( ($n[$i+1] - $start) == 2 )  { $s .= sprintf "to " }
        else { next }
    }
    if ( $bk && !$ah) {  $s .= sprintf "%d ",$n[$i] }
    #if (!$bk && $ah ) {  $s .= sprintf $n[$i] . " " }
    #print  " n:$n[$i]   bk:$bk  ah:$ah  start:$start\n";
}
$s.=sprintf "%d",$n[-1]; # append last member
say "" if $hash{debug};
say $s if $hash{debug};
return $s;
}

# ============================================================================
sub mlinestaad {
    #  takes a string and breaks it up for multi-line staad input 
    my $i = shift; # should be a string
    my $output;
    open FH, '>>', \$output;  #need to get a filehandle 
    write FH;
    close FH;
    $output =~s/ *- *$//; 
    return $output;
format FH =
^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<~~ -
$i
.
# ============ end of the format =============
}

# ============================================================================
sub getColumn {
    # need to be passed the contents of the clipboard.  It is in table
    # format with returns.
    my @lines = split /\r/, shift;
    my @n;
    foreach my $l  ( @lines)   {   # get first field and pack it into a list
        chomp $l;
        my @field;
        @field = split ' ',$l; #awk behavior
        print " $field[0]" if $hash{debug};
        push @n,$field[0];
    }
return @n
}

# ============================================================================
sub slurp_std {
    # input is a filename slurp returns the file as a string 
    # return a ref to an array of the lines.
    my $filename = shift;
    open FILEHANDLE, $filename or die $!;
    my @std_lines;
    my $ref = \@std_lines;
    while (<FILEHANDLE>) {
        chomp;
        push @std_lines, $_;
    }
    close FILEHANDLE;
    return \@std_lines;  
}
# ============================================================================

sub joint_coordinates {
    # input is ref to an array that has the .std lines
    # returns a ref to a Hash of Hashes
    my $ref= shift;
    my $capture = 0;
    my $slurp = "";
    foreach my $ln ( @{ $ref}  ) {
        if ( $ln =~ m/JOINT COORDINATES/i )    { $capture = 1;
#            print "turn on $ln \n";
            next
        }
        if ( $capture == 1 && $ln =~ m/^[a-z]/i ) {
            $capture = 0;
#            print "turn off $ln \n";
            next
        }
        if ( $capture == 1)  {
            if ( $ln =~ m/^\*/) { next }  #skip comments
            $slurp .= $ln;
        }
   }
   my @nodes =  split  / *; */,$slurp ;
   my $ref_HoH = {};
   foreach my $node (@nodes) {
       $node =~ s/^ +//;   #left trim
       $node =~ s/ +$// ;  #right trim
       #rint $node . "\n";
       my @set = split / +/, $node;  # split on spaces
       #say "first in set = $set[0]";
       $ref_HoH->{$set[0]}{x}=$set[1];
       $ref_HoH->{$set[0]}{y}=$set[2];
       $ref_HoH->{$set[0]}{z}=$set[3];
   }
   return $ref_HoH;
}
# ============================================================================

sub member_incidences {
    # input is ref to an array that has the .std lines
    # returns a ref to a Hash of Hashes
    my $ref = shift;
    my $capture = 0;
    my $slurp = "";
    foreach my $ln ( @{ $ref}  ) {
        if ( $ln =~ m/MEMBER INCIDENCES/i )    { 
            $capture = 1;
#            print "turn on $ln \n";
            next
        }
        if ( $capture == 1 && $ln =~ m/^[a-z]/i ) {
            $capture = 0;
#            print "turn off $ln \n";
            next
        }
        if ( $capture == 1)  {
            if ( $ln =~ m/^\*/) { next }  #skip comments
            $slurp .= $ln;
        }

   }
   my @members =  split  / *; */,$slurp ;
   my $ref_HoH = {};
   foreach my $memb (@members) {
       $memb =~ s/^ +//;   #left trim
       $memb =~ s/ +$// ;  #right trim
       #rint $node . "\n";
       my @set = split / +/, $memb;  # split on spaces
       #say "first in set = $set[0]";
       $ref_HoH->{$set[0]}{i}=$set[1];
       $ref_HoH->{$set[0]}{j}=$set[2];
   }
   return $ref_HoH;
}
# ============================================================================


#my @list = (1, 3, 5, 7, (10 ..117), 218, 224 ,244);
#say join " ", @list; 
#say "";
#say list2desc @list;
#say mlinestaad join " ",@list;
 

my $f = "Z:/Clients/TRN/ILDOT/98624_I-280/Design/Bridge/I-280 over Mississippi River/Working/RMH/Arch_model/Unit_5_arch.std";
my $ref_A =  slurp_std $f; 

#say join "\n", @{$ref_A} ; 
say member_incidences $ref_A   ;
say joint_coordinates $ref_A ;

1;   # modules return true to show they have loaded

