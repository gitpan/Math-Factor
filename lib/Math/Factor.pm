package Math::Factor;

$VERSION = '0.24';
@subs = qw(
    factor
    match 
    each_factor 
    each_match
);
@EXPORT_OK = @subs;
%EXPORT_TAGS = (all => [ @subs ]);

use strict 'vars';
use vars qw($Skip_multiple);
use integer;
use base qw(Exporter);
use Carp 'croak';

=head1 NAME

Math::Factor - Factorise numbers and calculate matching multiplications

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

Math::Factor factorises numbers by applying trial divison.

=head1 FUNCTIONS

=head2 factor

Factorises numbers.

 $factors = factor(\@numbers);

Each number within @numbers will be entirely factorised and its factors will be
saved within the hashref $factors, accessible by the number e.g the factors of 9 may
be accessed by @{$factors->{9}}.

Ranges may be evaluated by supplying a two-dimensional array. 

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
    croak 'usage: factor(\@numbers)' unless @$numbers;
    
    my $GROUND = 2;
    
    my(%factors, $number, $i, $limit);
    for (@$numbers) {
        $i = 0; 
        if (ref $_) { 
	    $number = $_->[0];
	    if ($_->[1] =~ /-/) { 
    	        my @range = split '-', $_->[1];
		$i = $range[0];
		$limit = $range[1] eq '$' ? $number : $range[1];
	    }
	    else { $limit = $number } 
	}
	else { 
	    $number = $limit = $_;
	}
	$i ||= $GROUND;
        for (; $i <= $limit; $i++) {
	    last if $i > ($number / 2);
            if ($number % $i == 0)  {  
                push @{$factors{$number}}, $i;
            }
        }
    }
    return \%factors;
}

=head2 match

Evaluates matching multiplications.

 $matches = match($factors);

The factors of each number within the hashref $factors will be multplicated against
each other and results that equal the number itself, will be saved to the hashref $matches.
The matches are accessible through the according numbers e.g. the first two numbers
that matched 9, may be accessed by $matches->{9}[0][0] and $matches->{9}[0][1], the second
ones by $matches->{9}[1][0] and $matches->{9}[1][1], and so on.

If $Math::Factor::Skip_multiple is set to a true value, matching multiplications 
that contain multiplicated (small) factors will be dropped.

Example: 

 # accepted 
 30107 == 11 * 2737  

 # dropped
 30107 == 77 * 391

=cut

sub match {
    my $factors = shift;
    croak 'usage: match($factors)' unless %$factors;

    my(%matches, $i, @previous_bases, $skip);
    for (keys %$factors) {
        $i = 0;
        my @cmp = my @base = @{$factors->{$_}};
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
    my($number, $factors) = @_;
    croak 'usage: each_factor($number, $factors)'
      unless $number && %$factors;

    my $FACTORS = __PACKAGE__."::each_factor_$number"; 
       
    unless (${$FACTORS}) {
        @{$FACTORS} = @{$factors->{$number}};
        ${$FACTORS} = 1;
    }
    if (@{$FACTORS}) {
        return shift @{$FACTORS};
    }
    else { 
        ${$FACTORS} = 0; 
	return ();
    }
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
    my($number, $matches) = @_;
    croak 'usage: each_match($number, $matches)'
      unless $number && %$matches;

    my $MATCHES = __PACKAGE__."::each_match_$number";
    
    unless (${$MATCHES}) {
        @{$MATCHES} = @{$matches->{$number}};
        ${$MATCHES} = 1;
    }
    if (wantarray && @{$MATCHES}) {
        my @match = @{${$MATCHES}[0]}; 
        shift @{$MATCHES};
        return @match;
    }
    else { 
        ${$MATCHES} = 0; 
	return (); 
    }
}

1;
__END__

=head1 EXPORT

C<factor(), match(), each_factor(), each_match()> are exportable.

B<TAGS>

C<:all - *()>

=cut
