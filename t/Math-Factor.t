#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;

use Math::Factor q/:all/;

BEGIN {
    my $PACKAGE = 'Math::Factor';
    use_ok($PACKAGE);
    require_ok($PACKAGE);
    print "\n";
}

my @numbers = (348226);

print "\@numbers = $numbers[0]\;\n\n";

my %factors = factor(\@numbers);
is($factors{$numbers[0]}[3], '314', 'factor (\@numbers)'."\n");
ok($factors{$numbers[0]}[2] == 157, 'factor: 157');
ok($factors{$numbers[0]}[6] == 174113, 'factor: 174113');

print "\n";

my %match = match(\%factors);
is($match{$numbers[0]}[2][1], '2218', 'match (\%factors)'."\n");
ok($numbers[0] == $match{$numbers[0]}[2][0] * $match{$numbers[0]}[2][1],
  "$numbers[0] == $match{$numbers[0]}[2][0] * $match{$numbers[0]}[2][1]");
ok($numbers[0] == $match{$numbers[0]}[3][0] * $match{$numbers[0]}[3][1],
  "$numbers[0] == $match{$numbers[0]}[3][0] * $match{$numbers[0]}[3][1]");