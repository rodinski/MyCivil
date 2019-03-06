package Line;
use Moo;
use Data::Dumper;
use Type::Tiny;
use Types::Standard qw( Str Int ArrayRef HashRef );
use Scalar::Util qw( looks_like_number);
use Math::Trig qw( pi  rad2deg deg2rad );
use Carp qw( confess ); 
use feature 'say';

#has 'start' => ( is => 'rw', required => 1,   );
has pa => (
    is  => 'rw',
    required => 0,  #might be nice to do methods on just the bearing
    isa => sub {  confess "'$_[0]' is not a Point Hash!"
        unless  $_[0] =~/Point=HASH/ }
);
has bearing =>     ( is => 'rw', required => 1, 
    isa => sub {  
      confess "'$_[0]' is not a not number!"
        unless  looks_like_number $_[0]  }
               );
has ID =>    ( is => 'rw', required => 0 ) ;
has tags =>  ( is => 'rw', required => 0 ) ;

sub is_parallel {
    my ( $self, $in_number  ) = @_;
    say  $self->bearing;
    say  $in_number;
    my $L = Line->new(bearing => $in_number ); 
    return (abs ($self->normalize - 
                 $L->normalize ) < 0.0000001);
}
sub normal  { my ($self) = @_; return $self->bearing + pi/2.0; }
sub b_deg   {  my ($self) = @_; rad2deg $self->bearing }
sub normalize {  my ($self) = @_;
         atan2 ( sin($self->bearing ),  cos($self->bearing ) )  }

# method offset should produce a new Line
sub offset { 
    my ( $self, $os_len  ) = @_;
    my $norm = $self->normal;
    #say "calc'd normal $norm with an offset of $os_len" ;
    my $new_N = $self->pa->N + $os_len * cos $norm;
    my $new_E = $self->pa->E + $os_len * sin $norm;
    my $new_pt = Point->new(  N => $new_N,  
                              E => $new_E  );
    my $new_br = $self->bearing ;
    return Line->new( pa => $new_pt, bearing => $new_br );
}
1;
