use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my %h = {};

%h =  (
    'spans'   =>  [  55.5, 80, 80, 55.5 ],
    'end_l'   =>  0.75,
    'pier_l'  =>  0.75
);

print Dumper  \%h; 
#

__DATA__
-.75    .75 .75 .75
 .75    .75 .75 -75
50.5    80  80  50.5

2.5     .5
6       2
9       2.5
10      4





