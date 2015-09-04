#!/usr/bin/env perl
=head1 NAME

    app.pl

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
use Dancer;
use Data::Dumper;
use ARS_App;

set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'session'      => 'Simple';
set 'log'          => 'debug';
set 'serializer'   => 'JSON'; 
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'layout'       => 'main';


hook before_template => sub {
       my $tokens = shift;
        
       $tokens->{'css_url'}           = request->base . 'css/style.css';
       $tokens->{'login_url'}         = uri_for('/login');
       $tokens->{'logout_url'}        = uri_for('/logout');
       $tokens->{'upload_url'}        = uri_for('/upload');
       $tokens->{'ars_redux_url'}     = uri_for('/redux');
       $tokens->{'ars_reduxfile_url'} = uri_for('/reduxfile');
};

start;
