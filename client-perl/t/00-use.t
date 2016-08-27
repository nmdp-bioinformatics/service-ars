#!/usr/bin/env perl
=head1 NAME

    00-allele.t

=head1 SYNOPSIS

    prove t/00-allele.t

=head1 AUTHOR     Mike Halagan <mhalagan@nmdp.org>
    
    Bioinformatics Scientist
    3001 Broadway Stree NE
    Minneapolis, MN 55413
    ext. 8225

=head1 DESCRIPTION


=head1 CAVEATS

=head1 OUTPUT


=head1 LICENSE

    Copyright (c) 2015 National Marrow Donor Program (NMDP)

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation; either version 3 of the License, or (at
    your option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; with out even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
    License for more details.
 
    You should have received a copy of the GNU Lesser General Public License
    along with this library;  if not, write to the Free Software Foundation,
    Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA.

    > http://www.gnu.org/licenses/lgpl.html   

=cut
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../lib";
use ARS_Client;
my $number_of_tests_run = 0; # Number of tests run

is(1,1);$number_of_tests_run++;

done_testing( $number_of_tests_run );












