#!/usr/bin/env perl
=head1 NAME

    ARS_Client

=head1 SYNOPSIS


=head1 AUTHOR     Mike Halagan <mhalagan@nmdp.org>
    
    Bioinformatics Scientist
    3001 Broadway Stree NE
    Minneapolis, MN 55413
    ext. 8225

=head1 DESCRIPTION

    This script takes in the output of ngs-validate-interp and the observed file and generates
    a static HTML website report.

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
package Validate_Client;
use strict;
use warnings;

use REST::Client;
use JSON;


my %h_cache;
my $service_url = 'http://localhost:3000';

=head2 redux

	
=cut
sub validate{

	my($s_allele,$s_db_version) = @_;

	my $client = REST::Client->new({
			host    => $service_url,
		});
	$client->addHeader('Accept', 'application/json');

	print STDERR $s_allele,"\t",$s_db_version,"\n";

	my $request = '?allele='.$s_allele."&dbversion=".$s_db_version;

	# List of haplotypes based on the first population
	$client->GET('/api/v1/validate' . $request);

	my $json_response = $client->responseContent;
	my $response = JSON::from_json($json_response);

	my $b_valid = $response->{valid};

	return $b_valid;

}

=head2 redux_cached

	
=cut
sub validate_cached{

	my($s_allele,$s_db_version) = @_;

	return $h_cache{$s_allele}{$s_db_version}
		if defined $h_cache{$s_allele}{$s_db_version};

	my $client = REST::Client->new({
			host    => $service_url,
		});
	$client->addHeader('Accept', 'application/json');

	#my $url = '/api/v1/?detailRace=' . $detail_race . "&ethnicity=" . $ethnicity;

	my $request = '?allele='.$s_allele."&dbversion=".$s_db_version;

	# List of haplotypes based on the first population
	$client->GET('/api/v1/validate' . $request);

	my $json_response = $client->responseContent;
	my $response = JSON::from_json($json_response);

	my $b_valid = $response->{valid};

    $h_cache{$s_allele}{$s_db_version} = $b_valid;


}

=head2 clear_cache

	
=cut
sub clear_cache{
	%h_cache = ();
}


=head2 set_url

	
=cut
sub set_service_url{
	$service_url = shift;
}


1;