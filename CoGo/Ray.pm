package Ray;
use My::CoGo::Bearing;
use My::CoGo::Point;
use Moo;

sub obj_test { 
  my($invocant,$class) = @_;
  my $whoami = Scalar::Util::blessed($invocant);
  die "$_[0] is " . ref $_[0] unless ( $whoami eq $class);
}
has 'name' => (
    is       => 'ro',
    required => 1,
);
has point => (
    is  => 'ro',
    isa => sub {
        die "$_[0] is " . ref $_[0] unless (1);
    },
);

has bearing => (
    is  => 'ro',
    isa => sub {
        die "$_[0] is " . ref $_[0] unless (1);
    },
);


1;

