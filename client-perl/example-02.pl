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
BEGIN{

    my $working    = `pwd`;chomp($working);
    if($working !~ /\/t/){
        my $lib = $working."/lib";
        push(@INC,$lib);
    }else{
        $working =~ s/\/t//;
        my $lib = $working."/lib";
        push(@INC,$lib);
    }
    
    push(@INC,"../lib/");


}
use Validate_Client;


my $s_db_version = shift @ARGV or die "No db version provided!\n";
my $s_allele     = shift @ARGV or die "No glstring provided!\n";
my $b_valid      = Validate_Client::validate($s_allele,$s_db_version);

print "Valid: ",$s_db_version,"\t",$s_allele,"\t",$b_valid,"\n";



exit 1;






















