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

use POSIX qw(strftime);
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

my %h_client_zips = (
	"perl-ars-client-v1.0.0.zip"    => '/downloads/perl-ars-client-v1.0.0.zip',
	"perl-ars-client-v1.0.0.tar.gz" => '/downloads/perl-ars-client-v1.0.0.tar.gz',
	"ars-client-0.0.1-SNAPSHOT.jar" => '/downloads/ars-client-0.0.1-SNAPSHOT.jar',
	"ars_file"                      => '/downloads/ars_redux.txt'
);

=head2 index

	
=cut
get '/' => sub {
	deleteOldFiles();
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
	my $dir      = $working."/public/downloads/".$filename;

	$file->copy_to("$dir");
	my $fh        = $file->file_handle;
	my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	my $glstring  = params->{'glstring'};
	my $expandAC  = params->{'expandAC'};
	my $expandGe  = params->{'expandGen'};
	my $expandGn  = params->{'expandGeno'};
	my $removeArs = params->{'removeArs'};
	my $macUrl    = params->{'url'};
	my $arsFile   = params->{'arsFile'};
	$dbversion    =~ s/\.//g;

	my $date = strftime "%m-%d-%Y", localtime;
	my $outname  = "Ars_".$arsType.".".$date.".csv";
	my $out_file = $working."/public/downloads/".$outname;

	my @a_data;
	if(-e $dir){
	    open(my $fh_out,">",$out_file) or die "CANT OPEN FILE $! $0";
	    foreach(`ngs-extract-expected-haploids -i $dir`){
	    	chomp;
	    	#1000-0000-0     HLA-A   HLA     IMGT/HLA        3.17.0  HLA-A*01:01:01:01+HLA-A*02:01:01:01
	    	my($id,$s_locus,$gene,$imgt,$imgt_db,$glstring) = split(/\t/,$_);
	    	$glstring =~ s/HLA-//g;

	    	my $invalidGlFormat = validGlstring($glstring,$dbversion);
			my $invalidAlleles  = invalidAlleles($glstring,$dbversion,$arsFile);

	    	if(defined $invalidGlFormat || defined $invalidAlleles){
	    		if(defined $invalidGlFormat){
		    		print $fh_out join(",",$id,$glstring,$invalidGlFormat),"\n";
	    			push @a_data, {
			          reduced  => $invalidGlFormat,			     	
			          glstring => $glstring,
			          count    => $id
			    	};
			    }
			    if(defined $invalidAlleles){
		    		print $fh_out join(",",$id,$glstring,$invalidAlleles),"\n";
	    			push @a_data, {
			          reduced  => "Invalid Alleles! ".$invalidAlleles,			     	
			          glstring => $glstring,
			          count    => $id
			    	};			    	
			    }
	    	}else{
	    		
		    	my $s_glstring = $ars->redux($glstring,$dbversion,$arsType,$arsFile,$expandAC,$expandGe,$expandGn,$removeArs,$macUrl);
				$s_glstring = defined $expandGe ? $ars->expandGenomic($s_glstring,$dbversion,$macUrl,$arsFile) : $s_glstring;
				$s_glstring = $ars->expandGenos($s_glstring)   if defined $expandGn && $expandGn =~ /\S/;

	    		$s_glstring = join("\n",unpack("(A164)*",$s_glstring))
					if(length($s_glstring)  > 164);

			    push @a_data, {
			          reduced  => $s_glstring,		
			          glstring => $glstring,
			          count    => $id
			     };
	    		print $fh_out join(",",$id,$glstring,$s_glstring),"\n";
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
        'reduced_glstring'  => \@a_data,
        'download'          => $outname
   	};

};



=head2 reduxfile

	

=cut
# post '/reduxfile' => sub {

#  	my $file     = request->upload('filename');
#  	my $filename = $file->filename;

#     # then you can do several things with that file
#     my $working  = `pwd`;chomp($working);
#     my $dir      = $working."/".$filename;
#     my $out_file = $working."/public/downloads/ars_redux.txt";

#     $file->copy_to("$dir");
#     my $fh        = $file->file_handle;
#     my $arsType   = params->{'arsType'};
# 	my $dbversion = params->{'dbversion'};
# 	$dbversion    =~ s/\.//g;

# 	my @a_data;
# 	if(-e $dir){
# 		my $cnt = 0;
# 		open(my $fh_out,">",$out_file) or die "CANT OPEN FILE $! $0";
# 	    open($fh,"<",$dir) or die "CANT OPEN FILE $! $0";
# 	    while(<$fh>){
# 	    	chomp;

# 	    	my $invalidGlFormat = validGlstring($_,$dbversion);
#     		my $invalidAlleles  = invalidAlleles($_,$dbversion);

# 	    	if(defined $invalidGlFormat || defined $invalidAlleles){
# 	    		if(defined $invalidGlFormat){
# 		    		print $fh_out join(",",$cnt,$_,$invalidGlFormat),"\n";
# 	    			push @a_data, {
# 			          reduced  => $invalidGlFormat,			     	
# 			          glstring => $_,
# 			          count    => $cnt
# 			    	};
# 			    }
# 			    if(defined $invalidAlleles){
# 		    		print $fh_out join(",",$cnt,$_,$invalidAlleles),"\n";
# 	    			push @a_data, {
# 			          reduced  => "Invalid Alleles! ".$invalidAlleles,			     	
# 			          glstring => $_,
# 			          count    => $cnt
# 			    	};			    	
# 			    }
# 	    	}else{
	    		
# 	    		my $s_ars_marked   = $ars->redux_mark($_,$dbversion,$arsType);
# 	    		my $s_ars_glstring = $ars->redux($_,$dbversion,$arsType);

# 	    		$s_ars_marked = join("\n",unpack("(A164)*",$s_ars_marked))
# 					if(length($s_ars_marked)  > 164);

# 			    push @a_data, {
# 			          reduced  => $s_ars_marked,		
# 			          glstring => $_,
# 			          count    => $cnt
# 			     };
# 	    		print $fh_out join(",",$cnt,$_,$s_ars_glstring),"\n";
# 	    	}
# 	    	$cnt++;
# 	    }
# 	    close $fh;
# 	}else{
# 		template 'index', {
# 	        'error_glstring'  => $dir,
# 	        'error'           => "File Does not exist!"	                
# 	   };
# 	}

# 	template 'index', {
#         'reduced_glstring'  => \@a_data,
#         'download'          => "ars_file"
#    	};

# };


=head2 redux

	
=cut
get '/redux' => sub {

	my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	my $glstring  = params->{'glstring'};
	my $expandAC  = params->{'expandAC'};
	my $expandGe  = params->{'expandGen'};
	my $expandGn  = params->{'expandGeno'};
	my $removeArs = params->{'removeArs'};
	my $macUrl    = params->{'url'};
	my $arsFile   = params->{'arsFile'};

	$dbversion =~ s/\.//g;

	my $invalidGlFormat = validGlstring($glstring,$dbversion);
    my $invalidAlleles  = invalidAlleles($glstring,$dbversion,$arsFile);

	my @a_data;
	if(!defined $invalidGlFormat && !defined $invalidAlleles){

		my $s_glstring = $ars->redux($glstring,$dbversion,$arsType,$arsFile,$expandAC,$expandGe,$expandGn,$removeArs,$macUrl);
		$s_glstring = defined $expandGe ? $ars->expandGenomic($s_glstring,$dbversion,$macUrl,$arsFile) : $s_glstring;
		$s_glstring = $ars->expandGenos($s_glstring)   if defined $expandGn && $expandGn =~ /\S/;

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



=head2 reduxSubjects API Call

	curl --header "Content-type: application/json" --request POST 
	--data '{"arsFile":"hla_nom_g.txt","dbversion":"3.20.0","arsType":"G",
	"Subjects":[{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]},
	{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]}]}' 
	http://localhost:3000/api/v1/reduxSubjects

	curl --header "Content-type: application/json" --request POST
	 --data '{"arsFile":"hla_nom_g.txt","macUrl":"mac.b12x.org","dbversion":"3.20.0","arsType":"g",
	"Subjects":[{"SubjectID":1,"typing":["A*01:AB+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]},
	{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]}]}' 
	http://localhost:3000/api/v1/reduxSubjects

=cut
post '/api/v1/reduxSubjects' => sub {


	my $ra_subjects = params->{'Subjects'};
	my $arsType     = params->{'arsType'};
	my $dbversion   = params->{'dbversion'};
	my $expandAC    = params->{'expandAC'};
	my $expandGe    = params->{'expandGen'};
	my $expandGn    = params->{'expandGeno'};
	my $removeArs   = params->{'removeArs'};
	my $macUrl      = params->{'macUrl'};
	my $arsFile     = params->{'arsFile'};

    $dbversion  =~ s/\.//g;

    my @a_redux_subjects;
	foreach my $rh_subject (@$ra_subjects){

		my @a_redux_gls;
		my $ra_glstrings = $$rh_subject{typing};
		foreach my $glstring (@$ra_glstrings){

			$glstring =~ s/HLA-//g;
			my $invalidGlFormat = validGlstring($glstring,$dbversion);
		    my $invalidAlleles  = invalidAlleles($glstring,$dbversion,$arsFile);

		    if(defined $invalidGlFormat || defined $invalidAlleles){
		    	if(defined $invalidGlFormat){
			    	push(@a_redux_gls,{
						error => $invalidGlFormat
			    	});
				}
				if(defined $invalidAlleles){
			    	push(@a_redux_gls,{
						error => "Invalid Alleles! ".$invalidAlleles
				   });			
				}
		    }else{

		    	my $s_glstring = $ars->redux($glstring,$dbversion,$arsType,$arsFile,$expandAC,$expandGe,$expandGn,$removeArs,$macUrl);
				$s_glstring = defined $expandGe ? $ars->expandGenomic($s_glstring,$dbversion,$macUrl,$arsFile) : $s_glstring;
				$s_glstring = $ars->expandGenos($s_glstring)   if defined $expandGn && $expandGn =~ /\S/;

			    if($s_glstring =~ /Invalid/){
			    	push(@a_redux_gls,{
						error => $s_glstring
			    	});
				}else{
				   push(@a_redux_gls,$s_glstring);
				}
			}
		}

		push(@a_redux_subjects,{
			SubjectID => $$rh_subject{SubjectID},
			typing =>  \@a_redux_gls
		});	
	}

	return {
        arsType    => $arsType,
        dbversion  => $dbversion,
        macUrl     => $macUrl,
        Subjects   => \@a_redux_subjects
    };


};


=head2 redux API Call

	curl --header "Content-type: application/json" --request POST \ 
	--data '{"arsFile":"hla_nom_g.txt","glstring":"A*01:01","dbversion":"3.20.0","arsType":"G"}'  \
	http://localhost:3000/api/v1/redux
	
=cut
any ['get', 'post'] => '/api/v1/redux' => sub {

	my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	my $glstring  = params->{'glstring'};
	my $expandAC  = params->{'expandAC'};
	my $expandGe  = params->{'expandGen'};
	my $expandGn  = params->{'expandGeno'};
	my $removeArs = params->{'removeArs'};
	my $macUrl    = params->{'url'};
	my $arsFile   = params->{'arsFile'};

    $dbversion  =~ s/\.//g;
    
	my $invalidGlFormat = validGlstring($glstring,$dbversion);
    my $invalidAlleles  = invalidAlleles($glstring,$dbversion,$arsFile);

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

    	my $s_glstring = $ars->redux($glstring,$dbversion,$arsType,$arsFile,$expandAC,$expandGe,$expandGn,$removeArs,$macUrl);
		$s_glstring = defined $expandGe ? $ars->expandGenomic($s_glstring,$dbversion,$macUrl,$arsFile) : $s_glstring;
		$s_glstring = $ars->expandGenos($s_glstring)   if defined $expandGn && $expandGn =~ /\S/;

	    if($s_glstring =~ /Invalid/){
		    return {
		        error => $s_glstring
		    };
		}else{
		    return {
		        dbversion => $dbversion,
		        arsType   => $arsType,
		        glstring  => $s_glstring
		    };
		}
	}

};

=head2 redux API Call

	http://localhost:3000/api/v1/ars
	** Returns all ARS data

	curl http://localhost:3000/api/v1/ars?arsType=G
	** Returns all G ARS data


	
=cut
get '/api/v1/ars' => sub {

	my $arsType   = params->{'arsType'};
	my $dbversion = params->{'dbversion'};
	my $arsFile   = params->{'arsFile'};

    $dbversion  =~ s/\.//g if defined $dbversion;

    $arsType   = !defined $arsType   ? undef : $arsType;
    $dbversion = !defined $dbversion ? undef : $dbversion;
    $arsFile   = !defined $arsFile   ? undef : $arsFile;

	my %h_invalid;
	if(defined $arsType && !$ars->validArsType($arsType)){
		$h_invalid{"Invalid Ars Type"} = $arsType;
	}
	if(defined $dbversion && !$ars->validDbVersion($dbversion)){
		$h_invalid{"Invalid IMGT DB"} = $arsType;
	}
	if(defined $arsFile && !$ars->validArsFile($arsFile)){
		$h_invalid{"Invalid Ars File"} = $arsFile;
	}

    if((scalar keys %h_invalid) >= 1){
	    return {
	    	error => \%h_invalid
	    };
    }else{
    	my $rh_ars_hash = $ars->getArsData($arsFile,$dbversion,$arsType);
    	if((scalar keys %$rh_ars_hash) <= 1){ 
    		return {
	    		error => join(" ",$arsType,$dbversion,$arsFile)
	    	};
		}else{
			return {
	    		%$rh_ars_hash
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

	my($glstring,$dbv,$s_nom_file) = @_;

	my %h_invalid;
	my $isInvalid = 0;
	map{ my $gl1 = $_; map{ my $gl2 = $_; map{ my $gl3 = $_;map{ my $gl4 = $_; 
		map{
			if(!$ars->isAC($_) && !$ars->isArsGroup($_,$dbv,$s_nom_file)){
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

=head2 deleteOldFiles

        Title:    deleteOldFiles
        Usage:    stripInvalid($glstring);
        Function: 
  
=cut
sub deleteOldFiles{

  my $date      = strftime "%m-%d-%Y", localtime;
  my $working   = `pwd`;chomp($working);
  my $dir       =  $working."/public/downloads";
  foreach my $s_file (glob("$dir/*.csv $dir/*.xml $dir/*.txt")){
    my @a_file = [$s_file, (stat $s_file)[9]];
    my $s_file_created = strftime("%m-%d-%Y", localtime $a_file[0]->[1]);
    if($s_file_created ne $date){
      system("rm $s_file");
    }
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
