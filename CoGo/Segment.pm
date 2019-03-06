package Segment;
use Moo;
use Data::Dumper;
use Type::Tiny;
use Types::Standard qw( Str Int ArrayRef HashRef );
use Scalar::Util qw( looks_like_number);
use Math::Trig qw( pi rad2deg deg2rad );
use Math::Round qw( round );

use Carp qw( confess ); 
use feature 'say';

has pa=> ( #should be Hash
     is => 'rw' 
    , required => 1 
    , isa => sub {  confess "'$_[0]' is not a Hash!"
        unless  $_[0] =~/Point=HASH/ }
);

has pb=> ( #should be Hash
    is => 'rw' 
    , required => 1 
    , isa => sub {  confess "'$_[0]' is not a Hash!"
        unless  $_[0] =~/Point=HASH/ }
);

has ID =>    ( is => 'rw', required => 0 ) ;
has tags =>  ( is => 'rw', required => 0 ) ;

sub bearing {
    my ( $self ) = @_; 
    return  atan2( $self->d_E, $self->d_N) ;
}

sub length {
    my ( $self ) = @_; 
    my $d_E = -$self->pa->E + $self->pb->E ;
    my $d_N = -$self->pa->N + $self->pb->N ;
    return sqrt($d_E**2 +$d_N**2);
} 

sub d_N {
    my ( $self ) = @_; 
    return $self->pb->{'N'} - $self->pa->{'N'};
}
sub d_E {
    my ( $self ) = @_; 
    return $self->pb->{'E'} - $self->pa->{'E'};
}
sub normal {
    my ( $self ) = @_; 
#    return -1/atan2($self->d_N,$self->d_E);
    return $self->bearing + pi;
}
sub normalize {  my ($self) = @_;
         $self->bearing; #by def b/c defined with the two points
       }


1;
