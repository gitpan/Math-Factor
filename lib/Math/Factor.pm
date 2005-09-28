package Math::Factor;

use base qw(Exporter);
use integer;
use strict;
use warnings;

use Carp 'croak';

our $VERSION = '0.29';
our $Skip_multiple;
our @subs = qw(factors matches);
our @EXPORT_OK = @subs;
our %EXPORT_TAGS = (all => [ @subs ]);

=head1 NAME

Math::Factor - Factorise numbers and calculate matching multiplications

=head1 SYNOPSIS

 use Math::Factor ':all';

 $number = 30107;

 @factors = factors($number);
 @matches = matches($number, @factors);

 print "$factors[1]\n";
 print "$number == $matches[0][0] * $matches[0][1]\n";

=head1 DESCRIPTION

Math::Factor factorises numbers by applying trial divison.

=head1 FUNCTIONS

=head2 factors

Factorises numbers.

 @factors = factors($number);

$number will be entirely factorised and its factors will be saved within 
the array @factors.

=cut

sub factors {
    my ($number) = @_;
    croak 'usage: factors($number)' unless $number;
  
    my (@factors, $i, $limit);
    
    for (my $i = 2; $i <= $number; $i++) {
        last if $i > ($number / 2);
	    
        if ($number % $i == 0)  {  
            push @factors, $i;
        }
    }
    
    return @factors;
}

=head2 matches

Evaluates matching multiplications.

 @matches = matches($number, @factors);

The factors within @factors will be multplicated against each other and results 
that equal the number itself, will be saved to the two-multidimensional array @matches.
The matches are accessible through the indexes, for example, the first two numbers
that matched the number, may be accessed by $matches[0][0] and $matches[0][1], 
the second ones by $matches[1][0] and $matches[1][1], and so on.

If $Math::Factor::Skip_multiple is set to a true value, matching multiplications 
that contain multiplicated (small) factors will be dropped.

Example: 

 # accepted 
 30107 == 11 * 2737  

 # dropped
 30107 == 77 * 391

=cut

sub matches {
    my ($number, @factors) = @_;
    croak 'usage: matches($number, @factors)' unless @_;

    my (@matches, @previous_bases, $skip);
    
    my $i = 0;
    my @base = my @cmp = @factors;
	
    for my $base (@base) { 
        for my $cmp (@cmp) {
            if ($cmp >= $base && $base * $cmp == $number) {
	        if ($Skip_multiple) {
		    $skip = 0;
			
	            for my $prev_base (@previous_bases) {
                        $skip = 1 if ($base % $prev_base == 0);
		    }
	        }    
	        unless ($skip) {
                    $matches[$i  ][0] = $base;
                    $matches[$i++][1] = $cmp;
		    push @previous_bases, $base if $Skip_multiple;
                }
            }
        }
    }
    
    return @matches;
}

1;
__END__

=head1 EXPORT

C<factors(), matches()> are exportable.

B<TAGS>

C<:all - *()>

=cut
