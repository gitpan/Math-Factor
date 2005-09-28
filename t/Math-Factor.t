#!/usr/bin/perl

use strict;
use warnings;

use Math::Factor ':all';
use Test::More tests => 4;

BEGIN {
    my $PACKAGE = 'Math::Factor';
    use_ok($PACKAGE);
    require_ok($PACKAGE);
}

my $number = 348226;
my @factors = factors($number);
my @matches = matches($number, @factors);

is($factors[2], 314, 'factors($number);');
is($matches[1][1], 2218, 'matches($number, @factors);');
