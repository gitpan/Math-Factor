# $Id: Factor.pm,v 0.15 2004/01/13 15:01:06 sts Exp $

package Math::Factor;

use 5.006;
use base qw(Exporter);
use integer;
use strict 'vars';
use warnings;

our $VERSION = '0.15';

our (@EXPORT_OK, %EXPORT_TAGS, @subs_factor,
     @subs_match, @subs);

@subs_factor = qw(factor each_factor);
@subs_match = qw(match each_match);
@subs = (@subs_factor, @subs_match);

@EXPORT_OK = @subs;
%EXPORT_TAGS = (  all     =>    [ @subs ],
                  factor  =>    [ @subs_factor ],
                  match   =>    [ @subs_match ],
);

sub GROUND { 1 }

sub croak {
    require Carp;
    &Carp::croak;
}

=head1 NAME

Math::Factor - factorise integers and calculate matching multiplications.

=head1 SYNOPSIS

 use Math::Factor q/:all/;

 @numbers = qw(9 30107);

 # data manipulation
 $factors = factor (\@numbers);
 $matches = match ($factors);

 # factors iteration
 while ($factor = each_factor ($numbers[0], $factors)) {
     print "$factor\n";
 }

 # matches iteration
 while (@match = each_match ($numbers[0], $matches)) {
     print "$numbers[0] == $match[0] * $match[1]\n";
 }

=head1 DESCRIPTION

see above.

=head1 FUNCTIONS

=head2 factor

Factorises numbers.

 $factors = factor (\@numbers);

Each number within @numbers will be entirely factorised and its factors will be
saved within the hash ref $factors, accessible by the number e.g the factors of 9 may
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
    my $numbers = $_[0];
    croak q~usage: factor (\@numbers)~
      unless @$numbers && ref $numbers eq 'ARRAY';

    my (%factor, $number, $i, $limit);
    foreach (@$numbers) {
        $i = 0; 
        if (ref $_) { 
	    $number = $$_[0];
	    if ($$_[1] =~ /-/) { 
    	        my @range = split /-/, $$_[1];
		$i = $range[0];
		if ($range[1] eq '$') { $limit = $number } 
		else { $limit = $range[1] }
	    }
	    else { $limit = $number } 
	}
	else { 
	    $number = $limit = $_;
	}
	$i = GROUND unless $i;
        for (; $i <= $limit; $i++) {
            if ($number % $i == 0)  {
                push @{$factor{$number}}, $i;
            }
        }
    }

    return \%factor;
}

=head2 match

Evaluates matching multiplications.

 $matches = match ($factors);

The factors of each number within the hash ref $factors will be multplicated against
each other and results that equal the number itself, will be saved to the hash ref $matches.
The matches are accessible through the according numbers e.g. the first two numbers
that matched 9, may be accessed by $$matches{9}[0][0] and $$matches{9}[0][1], the second
ones by $$matches{9}[1][0] and $$matches{9}[1][1], and so on.

=cut

sub match {
    my $factors = $_[0];
    croak q~usage: match ($factors)~
      unless %$factors && ref $factors eq 'HASH';

    my (%matches, $i);
    foreach (keys %$factors) {
        $i = 0;
        my @cmp = my @base = @{$$factors{$_}};
        foreach my $base (@base) {
            foreach my $cmp (@cmp) {
                if ($cmp >= $base) {
                    if ($base * $cmp == $_) {
                        $matches{$_}[$i][0] = $base;
                        $matches{$_}[$i][1] = $cmp;
                        $i++;
                    }
                }
            }
        }
    }

    return \%matches;
}

=head2 each_factor

Returns each factor of a number in a scalar context.

 while ($factor = each_factor ($number, $factors)) {
     print "$factor\n";
 }

If not all factors are being evaluated by each_factor(), 
it is recommended to undef @{"Math::Factor::each_factor_$number"}  
after usage of each_factor().

=cut

sub each_factor {
    my ($number, $factors) = @_;
    croak q~usage: each_factor ($number, $factors)~
      unless $number && ref $factors eq 'HASH';

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

Returns each match of a number in a array context.

 while (@match = each_match ($number, $matches)) {
     print "$number == $match[0] * $match[1]\n";
 }

If not all matches are being evaluated by each_match(), 
it is recommended to undef @{"Math::Factor::each_match_$number"}  
after usage of each_match().

=cut

sub each_match {
    my ($number, $matches) = @_;
    croak q~usage: each_match ($number, $matches)~
      unless $number && ref $matches eq 'HASH';

    unless (${__PACKAGE__."::each_match_$number"}) {
        @{__PACKAGE__."::each_match_$number"} = @{$$matches{$number}};
        ${__PACKAGE__."::each_match_$number"} = 1;
    }

    if (@{__PACKAGE__."::each_match_$number"} && wantarray) {
        my @match = (${__PACKAGE__."::each_match_$number"}[0][0], 
	  ${__PACKAGE__."::each_match_$number"}[0][1]);
        splice @{__PACKAGE__."::each_match_$number"}, 0, 1;
        return @match;
    }
    else { ${__PACKAGE__."::each_match_$number"} = 0; return }
}

1;
__END__

=head1 EXPORT

C<factor(), match(), each_factor(), each_match()> upon request.

B<TAGS>

C<:all - *()>

C<:factor - factor(), each_factor()>

C<:match - match(), each_match()>

=head1 SEE ALSO

perl(1)

=head1 LICENSE

This program is free software; 
you may redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Steven Schubiger

=cut
