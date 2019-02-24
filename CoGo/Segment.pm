package Segment;
use Moo;
use Type::Tiny::Class;
use Types::Standard qw( Str Int ArrayRef HashRef );
use Scalar::Util qw( looks_like_number);
use Data::Dumper;
use Carp qw( confess ); 

has pt0 => ( #should be Hash
     is => 'rw' 
    , required => 1 
    , default => sub { {} }
    , isa => sub { print $_[0]. "\n" }
    , isa => sub {  confess "'$_[0]' is not a Hash!"
        unless  $_[0] =~/Point=HASH/ }
);

has pt1 => ( #should be Hash
     is => 'rw' 
    , required => 1 
    , default => sub { {N=>0,E=>0} }
    , isa => sub { print $_[0]. "\n" }
    , isa => sub {  confess "'$_[0]' is not a Hash!"
         unless  $_[0] =~/Point=HASH/ }
);
has ID =>    ( is => 'rw', required => 0 ) ;
has tags =>  ( is => 'rw', required => 0 ) ;


sub distance {
    my ( $self ) = @_; 
    my $d_E = -$self->pt0->E + $self->pt1->E ;
    my $d_N = -$self->pt0->N + $self->pt1->N ;
    return sqrt($d_E**2 +$d_N**2);
} 

sub d_N {
    my ( $self ) = @_; 
    return $self->pt1->{'N'} - $self->pt0->{'N'};
}
sub d_E {
    my ( $self ) = @_; 
    return $self->pt1->{'E'} - $self->pt0->{'E'};
}
sub bearing {
    my ( $self ) = @_; 
    return atan2($self->d_N,$self->d_E);
}
sub normal {
    my ( $self ) = @_; 
    return -1/atan2($self->d_N,$self->d_E);
}

1;
