use Math::Factor q/:all/;

use strict;
use warnings;

my (@numbers, %factors, %match);

@numbers = qw(9 50 102 2321 30107
);

%factors = factor(\@numbers);
show_factor(\%factors);

%match = match(\%factors);
show_match(\%match);

