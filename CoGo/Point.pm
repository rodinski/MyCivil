package Point;
use Moo;
use Type::Tiny;
use Scalar::Util qw( looks_like_number);

# some test that Type::Tiny will do for us
my $NUM_TEST = "Type::Tiny"->new(
    name       => "Number",
    constraint => sub { looks_like_number($_)   },
    message    => sub { "$_ ain't a number" },
);

has E => ( is => 'rw', required => 1, isa => $NUM_TEST, );
has N => ( is => 'rw', required => 1, isa => $NUM_TEST, );
has y => ( is => 'rw', required => 1, default => undef, );
has x => ( is => 'rw', required => 0 );
has ID =>( is => 'r', required => 0 ) ;
has tags =>( is => 'rw', required => 0 ) ;



sub to_string {
    my ($self) = @_;
    return sprintf "[%s, %s]", $self->x, $self->y;
}

sub distance_from_origin {
    my ($self) = @_;
    my $sqr = $self->x**2 + $self->y**2;
    return sqrt($sqr);
}

sub translate {
    my ( $self, $dx, $dy ) = @_;

    my $x_temp = $self->x;
    $x_temp += $dx;
    $self->x($x_temp);
    $self->y( $self->y + $dy );
    return;
}

sub bearing_from_N {
    my ($self) = @_;
    my $bearing_from_N = atan2( $self->y, $self->x );
    return $bearing_from_N;
}




package Bearing;
use Moo;
use Math::Trig qw( :pi rad2deg );
use Type::Tiny;
use Scalar::Util qw( looks_like_number);

my $BEARING_TEST = "Type::Tiny"->new(
    name       => "Number",
    constraint => sub { looks_like_number($_)  && -pi < $_ && $_<= pi },
    message    => sub { "$_ ain't a number or isn't b/w -pi to pi" },
);
has bearing => ( 
    is => 'rw', 
    required => 1, 
    isa => $BEARING_TEST 
);

sub b   { my ($self) = @_; return $self->bearing; } 
sub deg { my ($self) = @_; return rad2deg $self->bearing }

1;

