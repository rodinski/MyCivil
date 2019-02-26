package Ray;
use My::CoGo::Bearing;
use My::CoGo::Point;
use Moo;
use Scalar::Util ( 'looks_like_number' );
use Carp qw( confess ); 
use feature ( 'say' );


#sub obj_test { 
#  my($invocant,$class) = @_;
#  say "invocant: $invocant";
#  say "class:    $class";
#  my $whoami = Scalar::Util::blessed($invocant);
#  say "whoami: $whoami";
#  die "$_[0] is " . ref $_[0] unless ( $whoami eq $class);
#}

has 'name' => (
    is       => 'rw',
    required => 1,
);
has point => (
    is  => 'rw',
    isa => sub {  confess "'$_[0]' is not a Point Hash!"
        unless  $_[0] =~/Point=HASH/ }
);

has bearing => (
    is  => 'rw',
    isa => sub {  confess "'$_[0]' is not a number!"
        unless   looks_like_number( $_[0] )  }
);


1;

