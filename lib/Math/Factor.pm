# $Id: Factor.pm,v 0.22 2004/01/18 07:31:17 sts Exp $

package Math::Factor;

use 5.006;
use base qw(Exporter);
use integer;
use strict 'vars';
use warnings;

our $VERSION = '0.22';

our (@EXPORT_OK, %EXPORT_TAGS, @subs);

@subs = qw(factor each_factor match each_match);

@EXPORT_OK = @subs;
%EXPORT_TAGS = (  all =>    [ @subs ],
);

our $Skip_multiple;

sub GROUND { 2 }

sub croak {
    require Carp;
    &Carp::croak;
}

=head1 NAME

Math::Factor - factorise numbers and calculate matching multiplications.

=head1 SYNOPSIS

 use Math::Factor ':all';

 @numbers = qw(9 30107);

 # data manipulation
 $factors = factor(\@numbers);
 $matches = match($factors);

 # factors iteration
 while ($factor = each_factor($numbers[0], $factors)) {
     print "$factor\n";
 }

 # matches iteration
 while (@match = each_match($numbers[0], $matches)) {
     print "$numbers[0] == $match[0] * $match[1]\n";
 }

=head1 DESCRIPTION

C<Math::Factor> factorises numbers by applying trial divison.

=head1 FUNCTIONS

=head2 factor

Factorises numbers.

 $factors = factor(\@numbers);

Each number within @numbers will be entirely factorised and its factors will be
saved within the hashref $factors, accessible by the number e.g the factors of 9 may
be accessed by @{$$factors{9}}.

Ranges may be evaluated by providing a two-dimensional array. 

 @numbers = (
     [ 9, '1-6' ],
     [ 1032, '1-$' ],
     [ 30107, '*' ],
 );

The first item (9) represents the number itself. The second item (1-6) represents
the range that is being evaluated; ranges are indicated by a starting and ending
value separated by a colon. $ indicates the number. Evaluating ranges for 
certain numbers may be entirely disabled by supplying *. 1-$ is equivalent to *.

=cut

sub factor {
    my $numbers = shift;
    croak q~Usage: factor(\@numbers)~ unless @$numbers;

    my (%factor, $number, $i, $limit);
    for (@$numbers) {
        $i = 0; 
        if (ref $_) { 
	    $number = $$_[0];
	    if ($$_[1] =~ /-/) { 
    	        my @range = split '-', $$_[1];
		$i = $range[0];
		if ($range[1] eq '$') { $limit = $number } 
		else { $limit = $range[1] }
	    }
	    else { $limit = $number } 
	}
	else { 
	    $number = $limit = $_;
	}
	$i ||= GROUND;
        for (; $i <= $limit; $i++) {
	    last if $i > $number / 2;
            if ($number % $i == 0)  {  
                push @{$factor{$number}}, $i;
            }
        }
    }

    return \%factor;
}

=head2 match

Evaluates matching multiplications.

 $matches = match($factors);

The factors of each number within the hashref $factors will be multplicated against
each other and results that equal the number itself, will be saved to the hashref $matches.
The matches are accessible through the according numbers e.g. the first two numbers
that matched 9, may be accessed by $$matches{9}[0][0] and $$matches{9}[0][1], the second
ones by $$matches{9}[1][0] and $$matches{9}[1][1], and so on.

If $Math::Factor::Skip_multiple is set true, matching multiplications that contain 
multiplicated (small) factors will be dropped.

Example: 

 # accepted 
 30107 == 11 * 2737  

 # dropped
 30107 == 77 * 391

=cut

sub match {
    my $factors = shift;
    croak q~Usage: match($factors)~ unless %$factors;

    my (%matches, $i, @previous_bases, $skip);
    for (keys %$factors) {
        $i = 0;
        my @cmp = my @base = @{$$factors{$_}};
        for my $base (@base) { 
            for my $cmp (@cmp) {
                if ($cmp >= $base && $base * $cmp == $_) {
		    if ($Skip_multiple) {
			$skip = 0;
			for (@previous_bases) {
			    $skip = 1 if $base % $_ == 0;
		        }
	            }    
	            if (!$skip) {
                        $matches{$_}[$i][0]   = $base;
                        $matches{$_}[$i++][1] = $cmp;
			push @previous_bases, $base if $Skip_multiple;
                    }
                }
            }
        }
    }

    return \%matches;
}

=head2 each_factor

Returns each factor of a number as string.

 while ($factor = each_factor($number, $factors)) {
     print "$factor\n";
 }

If not all factors are being evaluated by each_factor(), 
it is recommended to undef @{"Math::Factor::each_factor_$number"}  
after usage of each_factor().

=cut

sub each_factor {
    my ($number, $factors) = @_;
    croak q~Usage: each_factor($number, $factors)~
      unless $number && %$factors;

    unless (${__PACKAGE__."::each_factor_$number"}) {
        @{__PACKAGE__."::each_factor_$number"} = @{$$factors{$number}};
        ${__PACKAGE__."::each_factor_$number"} = 1;
    }

    if (@{__PACKAGE__."::each_factor_$number"}) {
        return shift @{__PACKAGE__."::each_factor_$number"};
    }
    else { ${__PACKAGE__."::each_factor_$number"} = 0; return }
}

=head2 each_match

Returns each match of a number as string.

 while (@match = each_match($number, $matches)) {
     print "$number == $match[0] * $match[1]\n";
 }

If not all matches are being evaluated by each_match(), 
it is recommended to undef @{"Math::Factor::each_match_$number"}  
after usage of each_match().

=cut

sub each_match {
    my ($number, $matches) = @_;
    croak q~Usage: each_match($number, $matches)~
      unless $number && %$matches;

    unless (${__PACKAGE__."::each_match_$number"}) {
        @{__PACKAGE__."::each_match_$number"} = @{$$matches{$number}};
        ${__PACKAGE__."::each_match_$number"} = 1;
    }

    if (@{__PACKAGE__."::each_match_$number"} && wantarray) {
        my @match = ${__PACKAGE__."::each_match_$number"}[0][0-1]; 
        splice @{__PACKAGE__."::each_match_$number"}, 0, 1;
        return @match;
    }
    else { ${__PACKAGE__."::each_match_$number"} = 0; return }
}

1;
__END__

=head1 EXPORT

C<factor(), match(), each_factor(), each_match()> are exportable.

B<TAGS>

C<:all - *()>

=cut
