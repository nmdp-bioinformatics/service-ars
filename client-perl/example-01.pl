#!/usr/bin/env perl
=head1 NAME

    example-00.pl

=head1 SYNOPSIS

    

=head1 AUTHOR     Mike Halagan <mhalagan@nmdp.org>
    
    Bioinformatics Scientist
    3001 Broadway Stree NE
    Minneapolis, MN 55413
    ext. 8225

=head1 DESCRIPTION


=head1 CAVEATS
	

=head1 LICENSE

    pipeline  Consensus assembly and allele interpretation pipeline.
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

=head1 VERSIONS
	
    Version    Description              Date


=head1 TODO
	

=head1 SUBROUTINES
	
=cut
use strict;
use warnings;
use Data::Dumper;
use ARS_Client;


# Loop through all of the ARS types

my $s_redux_type = shift @ARGV or die "No ARS Type provided!\n";
my $s_db_version = shift @ARGV or die "No db version provided!\n";
my $s_glstring   = shift @ARGV or die "No glstring provided!\n";

my $s_ars_gl = ARS_Client::redux($s_redux_type,$s_db_version,$s_glstring);

print "ARS Redux Type: ",$s_redux_type,"\tGL Before: ",$s_glstring,"\tReduced Glstring: ",$s_ars_gl,"\n";


exit 1;






















