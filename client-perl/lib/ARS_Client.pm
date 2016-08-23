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
package ARS_Client;
use strict;
use warnings;
use Data::Dumper;
use REST::Client;
use JSON;


=head2 redux

	
=cut
sub reduxSubjects{

	my($rh_params,$rh_subjects) = @_;

	my $request = {
		%$rh_params,
		Subjects => \@$rh_subjects
	};
	my $json_request = JSON::to_json($request);

	my $client = REST::Client->new({
			host    => $$rh_params{'arsUrl'},
		});
	$client->addHeader('Content-Type', 'application/json;charset=UTF-8');
	$client->addHeader('Accept', 'application/json');

	# List of haplotypes based on the first population
	$client->POST('/api/v1/reduxSubjects', $json_request, {});

	my $json_response = $client->responseContent;
	my $response = JSON::from_json($json_response);

	return $response;

}





1;