package Arc;
use Moo;
use Type::Tiny::Class;
use Types::Standard qw( Str Int ArrayRef HashRef );
use Scalar::Util qw( looks_like_number);
##use Math::Trig qw( :pi rad2deg );
use Data::Dumper;
use  My::CoGo::Point;
use Carp qw( confess ); 

has pt0 => ( #should be Segment Hash
     is => 'rw' 
    , required => 1 
    , default => sub { {{N=>0,E=>0}} }
    , isa => sub {  confess "'$_[0]' is not a Hash!"
          unless  $_[0] =~/Point=HASH/ }
);
has pt1 => ( #should be Hash
     is => 'rw' 
    , required => 1 
    , default => sub { {N=>0,E=>0} }
    , isa => sub {  confess "'$_[0]' is not Hash!"
          unless  $_[0] =~/Point=HASH/ }
);

has delta_angle => (  #should be Real
      is => 'rw' 
    , required => 1
    , default => sub { 0.0 }
    , isa => sub {  confess "'$_[0]' is not a real!"
          unless  looks_like_number ($_[0])  }
);

has ID =>    ( is => 'rw', required => 0 ) ;
has tags =>  ( is => 'rw', required => 0 ) ;


#needs work maybe a trans/rot
sub pt_end {
    my ( $self ) = @_; 
    my $r_seg = Segment->new( pt0 => $self->pt0, pt1 => $self->pt1);
    return $r_seg->normal ;
  }    
    


1;
