#! /usr/local/bin/perl

use strict;
use warnings;
use Math::Factor qw(factor match);

use Test::More tests => 4;

BEGIN {
    my $PACKAGE = 'Math::Factor';
    use_ok( $PACKAGE );
    require_ok( $PACKAGE );
}

my @numbers = (348226);
my $factors = factor( @numbers );
my $matches = match( $factors );

is( $factors->{$numbers[0]}[2], 314, 'factor( @numbers );' );
is( $matches->{$numbers[0]}[1][1], 2218, 'match( $factors );' );
