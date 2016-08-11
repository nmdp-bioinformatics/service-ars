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



=head1 CAVEATS
	

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

=head1 VERSIONS
	
    Version    		Description             	Date


=head1 TODO
	

=head1 SUBROUTINES

=cut
package ARS_App;
use Dancer ':syntax';
use Data::Dumper;
use ARS;

our $VERSION = '0.1';


# Initializing new ARS object
my $ars  = new ARS();
my %h_cached_glstrings;

# my $compare        = new Compare($ars);
# my $ra_dbs         = $compare->getDbs();
# my $rh_counts      = $compare->compareCounts($db1,$db2);
# my $rh_alleleCodes = $compare->compareAlleleCodes($db1,$db2);

my %h_valid_loci = (
	"A" => 1,"B" => 1,"C" => 1,
	"DRB1" => 1,"DQB1" => 1,"DQA1" => 1,
	"DRB3" => 1,"DRB4" => 1,"DRB5" => 1,
	"DRBX" => 1,"DQA1" => 1,"DPA1" => 1,
	"DPB1" => 1
);

my %h_client_zips = (
	"perl-ars-client-v1.0.0.zip"    => '/downloads/perl-ars-client-v1.0.0.zip',
	"perl-ars-client-v1.0.0.tar.gz" => '/downloads/perl-ars-client-v1.0.0.tar.gz',
	"ars-client-0.0.1-SNAPSHOT.jar" => '/downloads/ars-client-0.0.1-SNAPSHOT.jar',
	"ars_file"                      => '/downloads/ars_redux.txt'
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

=head2 clients

	
=cut
get '/soon' => sub {
    template 'soon';
};


=head2 clients

	
=cut
get '/clients' => sub {
    template 'clients';
};

=head2 download

	
=cut
get '/download' => sub {

	my $client_type = params->{type};
	$client_type = defined $client_type ? $client_type : "ars_file";

	if(defined $h_client_zips{$client_type}){
    	return send_file($h_client_zips{$client_type});
	}else{
		template 'error', {
        	'error'  => "Not a valid file client type"
		}
	}

	if($client_type eq "ars_file"){
		redirect '/';
	}else{
		redirect '/clients';
	}

};

=head2 reduxfile

	

=cut
post '/reduxfile' => sub {

 	my $file     = request->upload('filename');
 	my $filename = $file->filename;

    # then you can do several things with that file
    my $working  = `pwd`;chomp($working);
    my $dir      = $working."/".$filename;
    my $out_file = $working."/public/downloads/ars_redux.txt";

    $file->copy_to("$dir");
    my $fh        = $file->file_handle;
    my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	$dbversion    =~ s/\.//g;

	my @a_data;
	if(-e $dir){
		my $cnt = 0;
		#open(my $fh_out,">",$out_file) or die "CANT OPEN FILE $! $0";
	    open($fh,"<",$dir) or die "CANT OPEN FILE $! $0";
	    while(<$fh>){
	    	chomp;

	    	my $invalidGlFormat = validGlstring($_,$dbversion);
    		my $invalidAlleles  = invalidAlleles($_,$dbversion);

	    	if(defined $invalidGlFormat || defined $invalidAlleles){
	    		if(defined $invalidGlFormat){
		    		#print $fh_out join(",",$cnt,$_,$invalidGlFormat),"\n";
	    			push @a_data, {
			          reduced  => $invalidGlFormat,			     	
			          glstring => $_,
			          count    => $cnt
			    	};
			    }
			    if(defined $invalidAlleles){
		    		#print $fh_out join(",",$cnt,$_,$invalidAlleles),"\n";
	    			push @a_data, {
			          reduced  => "Invalid Alleles! ".$invalidAlleles,			     	
			          glstring => $_,
			          count    => $cnt
			    	};			    	
			    }
	    	}else{
	    		
	    		my $s_ars_marked   = $ars->redux_mark($_,$dbversion,$arsType);
	    		my $s_ars_glstring = $ars->redux($_,$dbversion,$arsType);

	    		$s_ars_marked = join("\n",unpack("(A164)*",$s_ars_marked))
					if(length($s_ars_marked)  > 164);

			    push @a_data, {
			          reduced  => $s_ars_marked,		
			          glstring => $_,
			          count    => $cnt
			     };
	    		#print $fh_out join(",",$cnt,$_,$s_ars_glstring),"\n";
	    	}
	    	$cnt++;
	    }
	    close $fh;
	}else{
		template 'index', {
	        'error_glstring'  => $dir,
	        'error'           => "File Does not exist!"	                
	   };
	}

	template 'index', {
        'reduced_glstring'  => \@a_data,
        'download'          => "ars_file"
   	};

};


=head2 redux

	
=cut
get '/redux' => sub {

	my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	my $glstring  = params->{'glstring'};

	$dbversion =~ s/\.//g;

	my $invalidGlFormat = validGlstring($glstring,$dbversion);
    my $invalidAlleles  = invalidAlleles($glstring,$dbversion);

	my @a_data;
	if(!defined $invalidGlFormat && !defined $invalidAlleles){
		my $s_glstring = $ars->redux_mark($glstring,$dbversion,$arsType);

		$s_glstring = join("\n",unpack("(A164)*",$s_glstring))
			if(length($s_glstring)  > 164);

		my %h_glstrings = (
			$glstring => $s_glstring
		);

		push @a_data, {
	          reduced  => $s_glstring,			     	
	          glstring => $glstring,
	          count => 0
	    };

	   template 'index', {
	        'reduced_glstring'  => \@a_data
	   };

	}else{
		if(defined $invalidGlFormat){
			template 'index', {
		        'error_glstring'  => $glstring,
		        'error'           => $invalidGlFormat	                
		   };
		}
		if(defined $invalidAlleles){
		   	template 'index', {
		        'error_glstring'  => $glstring,
		        'error'           => "Invalid Alleles! ".$invalidAlleles	                
		   };
		}
	}
		

};


=head2 compare

	
=cut
get '/compare' => sub {

	# my $db1  = params->{'dbversion1'};
	# my $db2  = params->{'dbversion2'};

	# $db1 =~ s/\.//g;
	# $db2 =~ s/\.//g;

	# my ($rh_cmp1,$rh_cmp2) = $cmp->compare($db1,$db2);

 #   template 'compare', {
 #        'db1'   => $db1,
 #        'db2'   => $db2,
 #        'cmp1'  => $rh_cmp,
 #        'cmp2'  => $rh_cmp2
 #   };


};

=head2 redux API Call
	
	
=cut
get '/api/v1/redux' => sub {

    my $dbversion = param('dbversion');
    my $ars_type  = param('arsType');
    my $glstring  = param('glstring');

    $glstring   =~ s/ /\+/g;
    $dbversion  =~ s/\.//g;
    $glstring   =~ /^(\D+\d{0,1})\*/;
    
    my $s_locus = $1;
	my $invalidGlFormat = validGlstring($glstring,$dbversion);
    my $invalidAlleles  = invalidAlleles($glstring,$dbversion);

    if(defined $invalidGlFormat || defined $invalidAlleles){
    	if(defined $invalidGlFormat){
	    	return {
				error => $invalidGlFormat
		    };
		}
		if(defined $invalidAlleles){
	    	return {
				error => "Invalid Alleles! ".$invalidAlleles
		    };			
		}
    }else{
    	my $s_ars_glstring = $ars->redux($glstring,$dbversion,$ars_type);

	    if($s_ars_glstring =~ /Invalid/){
		    return {
		        error => $s_ars_glstring
		    };
		}else{
		    return {
		        dbversion => $dbversion,
		        arsType   => $ars_type,
		        locus     => $s_locus,
		        glstring  => $s_ars_glstring
		    };
		}
	}

};


=head2 Validation API Call

	
=cut
get '/api/v1/validateAllele' => sub {

    my $dbversion = param('dbversion');
    my $allele    = param('allele');
    $dbversion =~ s/\.//g;

	my $validation = $ars->validateAllele($allele,$dbversion);
    my $b_valid    = $validation ? "TRUE" : "FALSE";

    return {
        allele     => $allele,
        dbversion  => $dbversion,
        valid      => $b_valid 
    };

};

=head2 Validation Glstring API Call

	
=cut
get '/api/v1/validGlstring' => sub {

    my $dbversion   = param('dbversion');
    my $glstring    = param('glstring');
    $dbversion =~ s/\.//g;

	my $invalidGlFormat = validGlstring($glstring,$dbversion);

    if(defined $invalidGlFormat){
    	return {
			validGl 	=> undef,
			invalid 	=> $glstring,
			dbversion 	=> $dbversion,
			error 		=> $invalidGlFormat
	    };
    }else{
    	my $valid_glstring = stripInvalid($glstring,$dbversion);
    	my $invalid 	   = invalidAlleles($glstring,$dbversion);
    	return {
	        validGl     => $valid_glstring,
	        glstring    => $glstring,
	        dbversion   => $dbversion,
	        invalid     => $invalid 
	    };
    }
   

};

=head2 valid

        Title:    valid
        Usage:    valid($glstring);
        Function: 
	
=cut
sub validGlstring{

	my($glstring,$dbv) = @_;

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

=head2 invalidAlleles

        Title:    invalidAlleles
        Usage:    invalidAlleles($glstring);
        Function: 
	
=cut
sub invalidAlleles{

	my($glstring,$dbv) = @_;

	my %h_invalid;
	my $isInvalid = 0;
	map{ my $gl1 = $_; map{ my $gl2 = $_; map{ my $gl3 = $_;map{ my $gl4 = $_; 
		map{
			if(!$ars->isAC($_) && !$ars->isArsGroup($_,$dbv)){
				my $b_valid = $ars->validateAllele($_,$dbv);
				if(!$b_valid){
					$isInvalid = 1;
					$h_invalid{$_}++;
				}
			}
		} split(/\//,$gl4); } split(/\~/,$gl3); } split(/\+/,$gl2)
	} split(/\|/,$gl1); } split(/\^/, $glstring);

	if($isInvalid){
		return join("/",keys %h_invalid);
	}else{
		return;
	}


}

=head2 stripInvalid

        Title:    stripInvalid
        Usage:    stripInvalid($glstring);
        Function: 
	
=cut
sub stripInvalid{

	my ($glstring,$dbv) = @_;

	return join '^', map(stripInvalid($_,$dbv), (split /\^/, $glstring))
		if ($glstring=~/\^/);
	return join '|', dedup((sort map(stripInvalid($_,$dbv), (split /\|/, $glstring))))
		if ($glstring=~/\|/);
	return join '+', (sort map(stripInvalid($_,$dbv), (split /\+/, $glstring)))
		if ($glstring=~/\+/);
	return join '~', dedup(map(stripInvalid($_,$dbv), (split /\~/, $glstring))) 
		if ($glstring=~/\~/);	
	return join '/', dedup(map(stripInvalid($_,$dbv), (split /\//, $glstring)))
		if ($glstring=~/\//);

	return $glstring if($ars->isArsGroup($glstring,$dbv));
	return $glstring if(!$ars->isAC($glstring) && $ars->validateAllele($glstring,$dbv));

	return;

}

=head2 stripInvalid

        Title:    stripInvalid
        Usage:    stripInvalid($glstring);
        Function: 
	
=cut
sub dedup {
  my @orig = @_;
  my %h;
  my @newlist;
  foreach my $i (@orig) {
    push @newlist, $i  unless defined $h{$i};
    $h{$i}++;
  }
  return @newlist;
}

true;
