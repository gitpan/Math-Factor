#! /usr/bin/perl

use strict;
use warnings;
use Math::Factor qw(factor match);

our (%form, $ul, $i);

#$Math::Factor::Skip_multiple = 1;
    
my @numbers = qw(9 30107);

my $factors = factor( @numbers );
my $matches = match( $factors );

show_factors( $factors );
show_matches( $matches );

sub show_factors {
    my ($factors) = @_;

    print <<'EOT';
-------
factors
-------

EOT
    
    local $_;
    for (sort { $a <=> $b } keys %$factors) {
        local ($ul, $,);   
        $ul = '-' x length;
	
        formeval( 'factors' ); 
	write; 
    
        $, = "\t"; 
        print "@{$factors->{$_}}\n\n";
    }
}

sub show_matches {
    my ($matches) = @_;   
	
    print <<'EOT';
-------
matches
-------

EOT

    local $_;
    for (sort { $a <=> $b } keys %$matches) {
        local ($ul, $i);
        $ul = '-' x length;
	
        formeval( 'match_number' ); 
	write;
    
        formeval( 'match_matches' ); 
        for ($i = 0; $matches->{$_}[$i]; $i++) { write }
	print "\n";
    }
}    

sub formeval {
    my ($ident) = @_;
    
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
