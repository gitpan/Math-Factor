#!/usr/bin/perl

use strict;
use warnings;
use Math::Factor qw(factor match);

our(@numbers, $factors, $matches, %form, $ul, $i);

#$Math::Factor::Skip_multiple = 1;
    
@numbers = qw(9 30107);

$factors = factor(\@numbers);
$matches = match($factors);

show_factors();
show_matches();

sub show_factors {
    print <<'EOT';
-------
factors
-------

EOT
    
    local $_;
    for (sort { $a <=> $b } keys %$factors) {
        local($ul, $,);   
        $ul = '-' x length;
        formeval('factors'); write; 
    
        $, = "\t"; 
        print "@{$factors->{$_}}\n\n";
    }
}

sub show_matches {	
    print <<'EOT';
-------
matches
-------

EOT

    local $_;
    for (sort { $a <=> $b } keys %$matches) {
        local($ul, $i);
        $ul = '-' x length;
        formeval('match_number'); write;
    
        formeval('match_matches'); 
        for ($i = 0; $matches->{$_}[$i]; $i++) { write }
        print "\n";
    }
}    

sub formeval {
    my $ident = shift;
    
    no warnings 'redefine';
    eval $form{$ident};
    die $@ if $@;
}

BEGIN {
    $form{factors} = '
    format =
@<<<<<<<<<<<<<<<<<<<<<<<<<
$_
@<<<<<<<<<<<<<<<<<<<<<<<<<
$ul
.';

    $form{match_number} = '
    format =
@<<<<<<<<<<<<<<<<<<<<<<<<<
$_
@<<<<<<<<<<<<<<<<<<<<<<<<<
$ul
.';

    $form{match_matches} = '
    format =
@<<<<<<<<<<<* @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$matches->{$_}[$i][0], $matches->{$_}[$i][1]
.';
}
