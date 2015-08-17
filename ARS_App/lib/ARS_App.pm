package ARS_App;
use Dancer ':syntax';
use ARS;

our $VERSION = '0.1';

my $ars  = new ARS();
my %h_cached_glstrings;

my %h_valid_loci = (
	"A" => 1,"B" => 1,"C" => 1,
	"DRB1" => 1,"DQB1" => 1,"DQA1" => 1,
	"DRB3" => 1,"DRB4" => 1,"DRB5" => 1,
	"DRBX" => 1,"DQA1" => 1,"DPA1" => 1,
	"DPB1" => 1
);

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

get '/' => sub {
    template 'index';
};


get '/about' => sub {
    template 'about';
};

get '/contact' => sub {
    template 'contact';
};

get '/login' => sub {
    template 'login';
};


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


true;
