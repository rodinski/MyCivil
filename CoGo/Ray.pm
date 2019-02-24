package Ray;
use Point;
use Moo;

has 'name' => (
    is       => 'ro',
    required => 1,
);
has 'point' => (
    is  => 'ro',
    isa => sub {
        die "$_[0] is " . ref $_[0] unless (1);
    },
);

has 'bearing' => (
    is  => 'ro',
    isa => sub {
        die "$_[0] is " . ref $_[0] unless (1);
    },
);
1;

