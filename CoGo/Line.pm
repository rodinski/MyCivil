package Line;
use Moo;
use Data::Dumper;
use Type::Tiny;
use Types::Standard qw( Str Int ArrayRef HashRef );
use Scalar::Util qw( looks_like_number);
use Carp qw( confess ); 

#has 'start' => ( is => 'rw', required => 1,   );
has pa => (
    is  => 'rw',
    isa => sub {  confess "'$_[0]' is not a Point Hash!"
        unless  $_[0] =~/Point=HASH/ }
);
has bearing =>     ( is => 'rw', required => 1, 
               isa => sub {  confess "'$_[0]' is not a number!"
                      unless looks_like_number $_[0]}
               );

1;
