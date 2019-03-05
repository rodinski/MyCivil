package Line;
use Moo;
use Data::Dumper;
use Type::Tiny;
use Types::Standard qw( Str Int ArrayRef HashRef );
use Scalar::Util qw( looks_like_number);
use Math::Trig qw( pi rad2deg deg2rad );
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
sub normal  { my ($self) = @_; return $self->bearing + pi; }
sub b_deg   {  my ($self) = @_; rad2deg $self->bearing }
sub normalize {  my ($self) = @_;
         atan2 ( sin($self->bearing ),  cos($self->bearing ) )  }

1;
