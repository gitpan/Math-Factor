#!/usr/bin/perl

use strict;
use warnings;

use Math::Factor qw/factor match/;

my (@numbers, %factors, %matches, $format_factors,
    $format_match_number, $format_match_matches);
    
@numbers = qw(9 30107);

%factors = factor(\@numbers);
%matches = match(\%factors);

print <<'EOT';
-------
FACTORS
-------

EOT

my $ul;
eval $format_factors; 
croak $@ if $@;

foreach (sort {$a <=> $b} keys %factors) {
    $ul = '-' x length;
    write; local $, = "\t";
    
    print <<"EOT";
@{$factors{$_}}


EOT
}	
			
print <<'EOT';
-------
MATCHES
-------

EOT

no warnings;
foreach (sort {$a <=> $b} keys %matches) {
    my $ul = '-' x length;

    eval $format_match_number;
    croak $@ if $@;
    write;

    my $i;
    eval $format_match_matches;
    croak $@ if $@;

    for ($i = 0; $matches{$_}[$i]; $i++) { write }

    print <<'EOT';


EOT
}

BEGIN {
$format_factors = '
  	format =
@<<<<<<<<<<<<<<<<<<<<<<<<<
$_
@<<<<<<<<<<<<<<<<<<<<<<<<<
$ul
.
';

$format_match_number = '
    format =
@<<<<<<<<<<<<<<<<<<<<<<<<<
$_
@<<<<<<<<<<<<<<<<<<<<<<<<<
$ul
.
';

$format_match_matches = '
    format =
@<<<<<<<<<<<* @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$matches{$_}[$i][0] $matches{$_}[$i][1]
.
';
}
