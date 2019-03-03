package Curve;
use Moo;
use Type::Tiny;
use Carp qw( confess ); 
use Scalar::Util qw( looks_like_number);
use Math::Trig qw( :pi rad2deg deg2rad );
use Data::Dumper;
#extends 'My::CoGo::Line';

#my $POINT_TEST = "Type::Tiny"->new(
#    name       => "Point",
#    constraint => sub { 0 },
#    message    => sub {  $_[-1] ." ". ref $_ . " ain't a number or isn't b/w -pi to pi" },
#);
has PC => (
    is  => 'rw',
    isa => sub {  confess "'$_[0]' is not a Point Hash!"
        unless  $_[0] =~/Point=HASH/ }
);
has CC => (
    is  => 'rw',
    isa => sub {  confess "'$_[0]' is not a Point Hash!"
        unless  $_[0] =~/Point=HASH/ }
);

has delta_angle  => ( 
    is => 'rw', 
    required => 1, 
);

sub R { 
    my ($self) = @_;
    my $seg = Segment->new( pt0=>$self->CC, pt1=>$self->PC );
    return $seg->length;
}

sub r { my ($self) = @_; 
    return $self->R }

sub delta_over_2 { my ($self) = @_; 
  return $self->delta_angle / 2.0 }

sub Arc { my ($self) = @_; 
  return $self->R * abs($self->delta_angle) }

sub Chord { my ($self) = @_; 
  return 2 * $self->R * sin (abs ($self->delta_over_2) ) }

sub M { my ($self) = @_; 
  return $self->R * (1 - cos $self->delta_over_2) }

sub External { my ($self) = @_; 
  return  $self->R * ( (1.0 /cos $self->delta_over_2 ) -1.0 ) }

sub PI { my ($self) = @_; 
  return  $self->R + $self->External }

sub DA { my ($self) = @_; 
  return  $self->delta_angle }

#sub PC { 
#  my ($self) = @_; 
#  my $x = $self->R - $self->M;
#  my $y = $self->Chord / 2.0 ;
#  my $p = Point->new(x=>$x, y=>$y);
#  return  $p }

sub PT { 
  my ($self) = @_; 
  my $x = $self->R - $self->M;
  my $y = -$self->Chord / 2.0 ;
  my $p = Point->new(x=>$x, y=>$y);
  return  $p }

1;
#
#               |
#               +
#               |  
#               |      
#               |
#               |
#   +           |
#   |           |
#---------------+------------------
#
