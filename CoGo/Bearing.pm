package Bearing;
use Moo;
use POSIX qw/floor/;
use Math::Trig qw( :pi rad2deg );
use Type::Tiny;
use Scalar::Util qw( looks_like_number);
use Data::Dumper;

my $BEARING_TEST = "Type::Tiny"->new(
    name       => "Number",
    constraint => sub { looks_like_number($_)},  #  && -pi < $_ && $_<= pi },
    message    => sub { "$_ ain't a number or isn't b/w -pi to pi" },
);

has bearing => ( 
    is => 'rw', 
    required => 1, 
    isa => $BEARING_TEST,
    trigger => 1  ,
    befor => 1, 
#    reader => 'get_bearing',
    writer => 'set_bearing'
  );

sub _before_bearing {
    my ($self) = @_;
    my $ang = $self->bearing;
    $self->set_bearing (atan2(sin $ang, cos $ang));
}

sub _trigger_bearing { 
   my ($self) = @_;
   my $ang = $self->bearing;
   # normalize whatever was in new method;
   $_[0]{bearing} =  atan2( sin($ang), cos($ang) );
   return ;
 }

sub N_per_E { 
  my ($self) = @_; return 1.0 / ( sin($self->b) / cos($self->b))}
sub y_per_x { 
  my ($self) = @_; return 1.0 / ( sin($self->b) / cos($self->b))}


sub b  { 
  my ($self) = @_; return $self->bearing; } 
sub normal  { 
   my ($self) = @_;
   if ($self->b >= 0) { return $self->b - pi } 
   else                 { return $self->b + pi }
}

sub b_deg { 
  my ($self) = @_; return rad2deg $self->bearing }
1;


