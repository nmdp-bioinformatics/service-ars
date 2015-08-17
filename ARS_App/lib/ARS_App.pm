#!/usr/bin/env perl
=head1 NAME

    ARS_App

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
package ARS_App;
use Dancer ':syntax';
use ARS;

our $VERSION = '0.1';

# Initializing new ARS object
my $ars  = new ARS();
my %h_cached_glstrings;

my %h_valid_loci = (
	"A" => 1,"B" => 1,"C" => 1,
	"DRB1" => 1,"DQB1" => 1,"DQA1" => 1,
	"DRB3" => 1,"DRB4" => 1,"DRB5" => 1,
	"DRBX" => 1,"DQA1" => 1,"DPA1" => 1,
	"DPB1" => 1
);


=head2 index

	
=cut
get '/' => sub {
    template 'index';
};

=head2 about

	
=cut
get '/about' => sub {
    template 'about';
};

=head2 contact

	
=cut
get '/contact' => sub {
    template 'contact';
};


=head2 login

	
=cut
get '/login' => sub {
    template 'login';
};


=head2 reduxfile

	
=cut
post '/reduxfile' => sub {

 	my $file     = request->upload('filename');
 	my $filename = $file->filename;

    # then you can do several things with that file
    my $working = `pwd`;chomp($working);
    my $dir     = $working."/".$filename;

    $file->copy_to("$dir");
    my $fh       = $file->file_handle;
    my $content  = $file->content;
    
    my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	$dbversion =~ s/\.//g;

	my %h_glstrings;
	if(-e $dir){


	    open($fh,"<",$dir) or die "CANT OPEN FILE $! $0";
	    while(<$fh>){
	    	chomp;
	    	my $s_error = isValid($_);

	    	if(defined $s_error){
	    		$h_glstrings{$_} = $s_error;
	    	}else{
	    		
	    		my $s_ars_glstring = $ars->redux_mark($_,$dbversion,$arsType);

	    		$s_ars_glstring = join("\n",unpack("(A164)*",$s_ars_glstring))
					if(length($s_ars_glstring)  > 164);

	    		$h_glstrings{$_} = $s_ars_glstring;
	    	}
	    }
	    close $fh;
	}else{

		template 'index', {
	        'error_glstring'  => $dir,
	        'error'           => "File Does not exist!"	                
	   };

	}

	template 'index', {
        'reduced_glstring'  => \%h_glstrings
   	};

};


=head2 redux

	
=cut
get '/redux' => sub {

	my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	my $glstring  = params->{'glstring'};

	$dbversion =~ s/\.//g;

	my $s_error = isValid($glstring);

	if(!defined $s_error){
		my $s_glstring = $ars->redux_mark($glstring,$dbversion,$arsType);

		$s_glstring = join("\n",unpack("(A164)*",$s_glstring))
			if(length($s_glstring)  > 164);

		my %h_glstrings = (
			$glstring => $s_glstring
		);

	   template 'index', {
	        'reduced_glstring'  => \%h_glstrings
	   };

	}else{

		template 'index', {
	        'error_glstring'  => $glstring,
	        'error'           => $s_error	                
	   };

	}
	

};



=head2 API Call

	
=cut
get '/api/v1/' => sub {

    my $db       = param('dbversion');
    my $ars_type = param('arsType');
    my $glstring = param('glstring');

    $glstring   =~ s/ /\+/g;
    $glstring   =~ /^(\D+\d{0,1})\*/;
    my $s_locus = $1;
	my $s_error = isValid($glstring);
    
    if(defined $s_error){
    	return {
			error => $s_error
	    };
    }else{
    	my $s_ars_glstring = $ars->redux($glstring,$db,$ars_type);
	    if($s_ars_glstring =~ /Invalid/){
		    return {
		        error => $s_ars_glstring
		    };
		}else{
		    return {
		        dbversion => $db,
		        arsType   => $ars_type,
		        locus     => $s_locus,
		        glstring  => $s_ars_glstring
		    };
		}
	}

};


=head2 isValid

        Title:    isValid
        Usage:    isValid($glstring);
        Function: 
	
=cut
sub isValid{

	my($glstring) = shift;

	return $h_cached_glstrings{$glstring}
		if(defined $h_cached_glstrings{$glstring});

	if(!defined $glstring || $glstring !~ /\S/ || $glstring !~ /\*/ || 
		$glstring !~ /\:/){
		$h_cached_glstrings{$glstring} = "No Glstring provided!";
		return "No Glstring provided!";
	}

	if($glstring =~ /\+\d+/){
		$h_cached_glstrings{$glstring} = "Invalid glstring! Missing locus!";
		return "Invalid glstring! Missing locus!";
	}

	if( $glstring =~ /\+$/ || $glstring =~ /\|$/ || $glstring =~ /^\|/ || 
		$glstring =~ /^\+/ || $glstring =~ /^\^/ || $glstring =~ /^\*/ || 
		$glstring =~ /\*$/ || $glstring =~ /\~$/ || $glstring =~ /^\~/ ){
		$h_cached_glstrings{$glstring} = "Invalid glstring!";
		return "Invalid glstring!"
	}

	foreach($glstring =~ /(\w+\d{0,1})\*/g){
		if(!defined $h_valid_loci{$_}){
			$h_cached_glstrings{$glstring} = "Invalid locus! $_";
			return "Invalid locus! $_";
		}
	}

	return;

}

true;
