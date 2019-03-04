package Point;
use Moo;
use Type::Tiny;
use Types::Standard qw( Str Int ArrayRef HashRef );
use Scalar::Util qw( looks_like_number);
use Carp qw( confess ); 
use Data::Dumper;

has N =>     ( is => 'rw', required => 1,
               isa => sub {  confess "'$_[0]' is not a number!"
                      unless looks_like_number $_[0]}
               );
has E =>     ( is => 'rw', required => 1, 
               isa => sub {  confess "'$_[0]' is not a number!"
                      unless looks_like_number $_[0]}
               );
has ID =>    ( is => 'rw', required => 0 ) ;
has tags =>  ( is => 'rw', required => 0 ) ;


sub to_string {
    my ($self) = @_;
    return sprintf "{ N=> %s, E=> %s }", $self->E, $self->N;
}

#translate  changes the points N&E
sub translate {
    my ( $self, %hash) = @_;
    my $dN =  $hash{ 'dN' };
    my $dE =  $hash{ 'dE' };
    #print Dumper $self;
    $self->N( $self->N + $dN );
    $self->E( $self->E + $dE );
    return;
}
sub rotate {
    my ( $self, %hash  ) = @_;
#    print Dumper $self;
#    print Dumper $hash;
    my $angle = $hash{ 'angle' };
    my ($n, $e);
    $n = ( $self->N *cos($angle) - $self->E *sin($angle)  );
    $e = ( $self->N *sin($angle) + $self->E *cos($angle)  );
    $self->N($n);
    $self->E($e);
    return ;
  }

1;
