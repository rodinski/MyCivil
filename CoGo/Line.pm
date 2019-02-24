package Line;
use Moo;
use Data::Dumper;
#use Type::Tiny;
#use Scalar::Util qw( looks_like_number);
#extends  'My::CoGo::Point' ;

# some test that Type::Tiny will do for us
#my $Pos_NUM_TEST = "Type::Tiny"->new(
#    name       => "Number",
#    constraint => sub { looks_like_number($_)  && $_ >= 0  },
#    message    => sub { "$_ ain't a number or not possitive" },
#);
#
#my $Point_Test = "Type::Tiny"->new(
#    name       => "Number",
#    constraint => sub { looks_like_number($_)   },
#    message    => sub { "$_ ain't a number" },
#);
#=============================================================

#has 'start' => ( is => 'rw', required => 1, isa => 'My::MyCivil::CoGo::Point'  );
#has 'start' => ( is => 'rw', required => 1, isa => 'Point'  );
has 'start' => ( is => 'rw', required => 1,   );
#has 'end'   => ( is => 'rw', required => 1, isa => 'My::MyCivil::CoGo::Point' );
has 'end'   => ( is => 'rw', required => 1, );

sub length {
    my ($self) = @_;
    print Dumper $self; 
    my $dN = $self->{start}{'N'} - $self->{end}{'N'} ;
    my $dE = $self->{start}{'E'} - $self->{end}{'E'} ;
    return sqrt( $dN**2 + $dE**2 ) 
  }

1;
