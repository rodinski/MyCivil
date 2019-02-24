package Angle;
use Moo;
use Math::Trig qw( :pi rad2deg );
use Type::Tiny;

use Scalar::Util qw( looks_like_number);
    name       => "Number",
    constraint => sub { looks_like_number($_)  && -pi < $_ && $_<= pi },
    message    => sub { "$_ ain't a number or isn't b/w -pi to pi" },

my $Angle = "Type::Tiny"->new();

1;
