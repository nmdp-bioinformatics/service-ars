#!/usr/bin/env perl
=head1 NAME

    ARS

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
use strict;;##################################################################
use warnings;;################################################################
use Fcntl;####################################################################
use Data::Dumper;#############################################################
use LWP::UserAgent;###########################################################
package ARS;##################################################################
##############################################################################
#	************	
#	** ARS.pm ** 	
#   ************
#
#	This package is for reducing a glstring or a single allele down to it's 
#	antigen recongnition site (ARS) equilavlent. This is done by using the ARS
#	equivalent tables from IMGT located here: 
#	For more information about the ARS region please refer to the Lunch&Learn Bob
#	Milius gave, which is located here: 	
#
#	README: /MDP/devel/research/lib/perl/files/README.ars 	
#
#	Initializing:
#		1) Create a database connection (ex. via Connect.pm)
#		2) Make sure "/MDP/devel/research/lib/perl/" is in your @INC
#		3) Make ars_redux object
#			- redux_type equals "g"       (*required*)
#			- dbversion equals "3.15.0"   (Default -> most current version)
#			- verbose equals 1            (Default -> 0)
#		    - my $ars = new ARS("nmdp","g","3.15.0",1);
#
#	Examples:
#		my $gl = "A*01:02/A*01:02/A*01:02/A*01:02+A*01:02/A*01:02/A*01:02/A*01:02|A*01:02/A*01:02/A*01:02+A*01:02/A*01:02";
#		my $gl_ars = $ars->redux($gl);
#		
#	Result:
#		A*01:01g+A*01:01g
#
#
#	*********************************************
#	************** Testing Script ***************
#	*********************************************
#	
#	For more detail on how to use the testing script please refer to the README.ars file. 
#
#	Location:
#		/MDP/devel/research/lib/perl/files/t 
#		
#	prove ars.t -v {verbosity}
#		- 	Without passing it any parameters this will first loop through the ARS tables and
#			make sure each allele is properly reducing to it's ars equivalent. Next it will pull in
#			these files:
#
#		
#			It will then run ARS reduction on the glstring.txt file and compare the results to glstring_ars.txt
#			and look for any differences. 
#
#	prove ars.t -i {file with glstrings} -e {expected output} -v {verbostiy}
#		- 	Instead of using the predefined glstring files you can pass it an input glstring file
#			and an expect ars glstring file. If you're doing this make sure that the expected glstring
#			file is accurate!
#
#
#	*********************************************
#	***** Scripts that currently use ARS.pm *****
#	*********************************************
#
#	pull_convert
#		- Location: /svn/
#		- Lines in Code:
#		- Use:
#
#	getRes_bmdw.pl
#		- Location: /svn/
#		- Lines in Code:
#		- Use:
#
#
#########################################################################
###                                                                   ###
## 	Please direct any questions to Michael Halagan (mhalagan@nmdp.org) ##
###                                                                   ### 
#########################################################################


####################################
### Initializing private methods ###
####################################
my $loadARS 	  = {};	# Method for loading ARS files
my $loadAC  	  = {}; # Method for loading AC tied hash
my $ARS_redux     = {}; # Method for doing ARS reduction
my $loadARSgit    = {};
my $ac2gl         = {};
my $isArs		  = {};
####################################
###  Initializing local hashes   ###
####################################
our %h_AC 		  = (); # Hash that holds all allele code data
our %h_cache	  = (); # Hash for caching ars results
our %h_valid_redux = (
	"g" => 1, "P" => 1,
	"gx" => 1,"G" => 1,
	"W" => 1,
);


my $working    = `pwd`;chomp($working);
my $s_ars_dir  = $working."/ARS";
my $s_wmda_dir = $working."/HLA-WMDA";

##########################
###   public methods   ###
##########################
##############################################################################
#     function: 	new ARS("nmdp","g","3.15.0", 1, 1)
#     description: 	Creates a new ARS object
#     input: 		my $ars = new ARS("G","3.8.0",$dbh);
#					Expansion type,db version, and db connection (If using one)
#     output:		
##############################################################################
sub new{

	my $class = shift();
	my $self = {};

    $self->{verbose} = shift(); #ARS reduction type
    $self->{acurl}   = shift();

    $self->{verbose} = !defined $self->{verbose} ? 0 : $self->{verbose};
	$self->{acurl}   = !defined $self->{acurl}   ? "http://opshmlservices2.b12x.org:8080/mac/" : $self->{acurl};

	bless($self, $class); #Create the ars object
   
	$self->$loadARS(); #Load the ARS files

	print STDERR "Finished initializing\n" if $self->{verbose};

	return($self);
}
##############################################################################
#     function: 	redux_cached
#     description: 	
#     input: 		glstring
#     output:		reduced glstring
##############################################################################
sub redux_cached{

	my ($self,$glstring,$dbv,$s_redux_type) = @_;
	
	return $h_cache{$glstring} if defined $h_cache{$glstring};
	my $s_ars_reduced = $self->redux($glstring,$dbv,$s_redux_type);
	$h_cache{$glstring} = $s_ars_reduced;
	
	return $s_ars_reduced;
	
}
##############################################################################
#     function: 	redux
#     description: 	
#     input: 		glstring
#     output:		reduced glstring
##############################################################################
sub redux {

	my ($self,$glstring,$dbv,$s_redux_type) = @_;

	return join '^', map($self->redux($_,$dbv,$s_redux_type), (split /\^/, $glstring))
		if ($glstring=~/\^/);
	return join '|', dedup((sort map($self->redux($_,$dbv,$s_redux_type), (split /\|/, $glstring))))
		if ($glstring=~/\|/);
	return join '+', (sort map($self->redux($_,$dbv,$s_redux_type), (split /\+/, $glstring)))
		if ($glstring=~/\+/);
	return join '~', dedup(map($self->redux($_,$dbv,$s_redux_type), (split /\~/, $glstring))) 
		if ($glstring=~/\~/);	
	return join '/', dedup(map($self->redux($_,$dbv,$s_redux_type), (split /\//, $glstring)))
		if ($glstring=~/\//);
	return join '/',dedup(map($self->redux($_,$dbv,$s_redux_type),(split /\//,$self->$ac2gl($glstring))))
		if isAC($glstring);
	
	if($glstring !~ /\S/ || $glstring !~ /\d{2,3}:(\d{2,3}|\D{2,6})/){
		print STDERR "Not a vaild allele! $! $glstring\n";
		return ""; 
	}

	$glstring = $self->$ARS_redux($glstring,$dbv,$s_redux_type);

	return $glstring;

}
##############################################################################
#     function: 	redux
#     description: 	
#     input: 		glstring
#     output:		reduced glstring
##############################################################################
sub redux_mark {

	my ($self,$glstring,$dbv,$s_redux_type) = @_;

	return join '^', map($self->redux_mark($_,$dbv,$s_redux_type), (split /\^/, $glstring))
		if ($glstring=~/\^/);
	return join '|', dedup((sort map($self->redux_mark($_,$dbv,$s_redux_type), (split /\|/, $glstring))))
		if ($glstring=~/\|/);
	return join '+', (sort map($self->redux_mark($_,$dbv,$s_redux_type), (split /\+/, $glstring)))
		if ($glstring=~/\+/);
	return join '~', dedup(map($self->redux_mark($_,$dbv,$s_redux_type), (split /\~/, $glstring))) 
		if ($glstring=~/\~/);	
	return join '/', dedup(map($self->redux_mark($_,$dbv,$s_redux_type), (split /\//, $glstring)))
		if ($glstring=~/\//);
	return join '/',dedup(map($self->redux_mark($_,$dbv,$s_redux_type),(split /\//,$self->$ac2gl($glstring))))
		if isAC($glstring);
	

	if($glstring !~ /\S/ || $glstring !~ /\d{2,3}:(\d{2,3}|\D{2,6})/){
		print STDERR "Not a vaild allele! $! $glstring\n";
		return ""; 
	}

	$glstring = $self->$ARS_redux($glstring,$dbv,$s_redux_type);

	if($self->$isArs($glstring,$dbv,$s_redux_type)){
		return "<span class=\"highlightGroup\">".$glstring."</span>";
	}else{
		return $glstring;
	}

}
##############################################################################
#     function: 	who2G
#     description: 	
#     input: 		
#     output:		
##############################################################################
sub who2G {
  my $typ = shift;
  my ($loc, $allele) = split /\*/, $typ;
  my @blocks = split /:/, $allele;
  return $typ unless scalar @blocks >=3;
  my $newallele = (join ':', (split /:/, $allele)[0..2]);
  return join '*', $loc, $newallele;
}
##############################################################################
#     function: 	
#     description: 	
#     input: 		
#     output:		
##############################################################################
sub who2p{
	my ($typ) = shift;

	my($loc,$allele) = split(/\*/,$typ);

	$loc =~ s/\*$//;
	my @blocks = split /:/, $allele;
	return $allele unless scalar @blocks >=2;
	my $newallele = (join ':', (split /:/, $allele)[0..1]);
	if($blocks[$#blocks] =~ /\d([L|N|S|Q]{1})$/ && $#blocks >= 2 ){
		return join '*', $loc, $newallele.$1;
	}
	return join '*', $loc, $newallele;
}
##############################################################################
#     function: 	isAC
#     description: 	
#     input: 		
#     output:		
##############################################################################
sub isAC{
	my $allele   = shift();
	if($allele =~ /\d\d\D{2,4}/ || $allele =~ /\d\d:\D{2,4}/){
		return 1;
	}else{ return 0;}
}
##############################################################################
#     function: 	getArsGroups
#     description: 	
#     input: 		
#     output:		
##############################################################################
sub getArsGroups{

	my($self,$s_glstring,$dbversion,$s_ars_type) = @_;

	my %h_groups;
	foreach my $s_p (split /\^/, $s_glstring){
		foreach my $s_g (split /\|/, $s_p){
			foreach my $s_h (split /\+/, $s_g){
				foreach my $s_a (split /\//, $s_h){
					$h_groups{$s_a}++ if($self->$isArs($s_a,$dbversion,$s_ars_type));
				}
			}		
		}
	}

	return \%h_groups;

}
##############################################################################
#     function: 	
#     description: 
#     input: 		
#     output:		
##############################################################################
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
##############################################################################
#     function: 	
#     description: 
#     input: 		
#     output:		
##############################################################################
sub clear_cache {
	%h_cache = ();
}
##############################################################################
#     function: 	cnt_grps
#     description: 	
#     input: 		
#     output:		
##############################################################################
sub cnt_grps{

	my $code = shift;
	my $alleles_ref = shift;
	my @alleles = @$alleles_ref;
	
	return 1 if $#alleles == 0;
	
	my %g_grps;
	foreach my $allele (@alleles){
		my $g_allele = (join ':', (split /:/, $allele)[0..1]);
		$g_grps{$g_allele}++;
	}
	
	my $grp_cnt = keys %g_grps;
	return 1 if $grp_cnt ==1;
	
}

##########################
###   private methods  ###
##########################
##############################################################################
#     function: 	$ARS_reduction
#     description: 			
#     input: 		N/A
#     output:		N/A
##############################################################################
$ARS_redux = sub{
	
	my ($self, $typing,$dbv,$s_redux_type) = @_;

	$typing = 
		($s_redux_type eq "P" || $s_redux_type eq "g" || $s_redux_type eq "gx") ?
		who2p($typing) : $typing;

	if( defined $self->{ARS}->{$dbv}->{$s_redux_type}->{$typing} ){
		print STDERR "Reducing $typing to ARS equivalent -> $self->{ARS}->{$typing}\n" if $self->{verbose};
		return $self->{ARS}->{$dbv}->{$s_redux_type}->{$typing};
	}
	
	return $typing;

};
##############################################################################
#     function: 	$ARS_reduction
#     description: 			
#     input: 		N/A
#     output:		N/A
##############################################################################
$isArs = sub{
	
	my ($self,$typing,$dbv,$s_redux_type) = @_;

	if(defined $self->{GROUPS}->{$dbv}->{$s_redux_type}->{$typing}){
		return 1;
	}else{
		return 0;
	}

};
##############################################################################
#     function: 	$loadARS
#     description: 	
#     input: 		
#     output:		N/A
##############################################################################
$loadARS = sub{
	
	my $self = shift();

	my @a_branches;
    print `git clone https://github.com/jrob119/HLA-WMDA`;
    foreach(`git --git-dir=$s_wmda_dir/.git branch -a`){
        chomp;
        if($_ =~ /\d{4}$/){
            $_ =~ s/ //g;
            push(@a_branches,$_);
        }
    }

    foreach my $s_branch (@a_branches){

    	print `git --git-dir=$s_wmda_dir/.git --work-tree=$s_wmda_dir checkout $s_branch`;
    	my $ars_file = $s_wmda_dir."/hla_nom_g.txt";

    	$s_branch      =~ /(\d{4})$/;
    	my $db_version = $1;

		open(my $fh_ars,"<",$ars_file) or die "CANT OPEN FILE $! $0";
		while(<$fh_ars>) {
			chomp;
			
			next if $_ =~ /^#/;
	        my($s_loc,$s_allele_list,$s_G_group) = split(/\;/,$_);

	        my $p_level_ars = (join ':', (split /:/, $s_G_group)[0..1]);
	        my $g_level_ars = $p_level_ars."g";

	        next unless defined $s_G_group && $s_G_group =~ /\S/;
	        my @a_alleles = split(/\//,$s_allele_list);

			my $g_gt_1 = cnt_grps($p_level_ars,\@a_alleles);
			next if $g_gt_1 == 1;

			foreach my $allele (@a_alleles) {
			
				next unless $allele=~/\S/;
				my $p_res = who2p($s_loc.$allele);
				my $g_res = who2G($s_loc.$allele);



				$self->{ARS}->{$db_version}->{G}->{$g_res}  = $s_loc.$s_G_group;
				$self->{ARS}->{$db_version}->{G}->{$p_res}  = $s_loc.$s_G_group;
				$self->{ARS}->{$db_version}->{G}->{$allele} = $s_loc.$s_G_group;

				$self->{ARS}->{$db_version}->{g}->{$p_res} = $s_loc.$g_level_ars;
				$self->{ARS}->{$db_version}->{P}->{$p_res} = $s_loc.$p_level_ars if $allele !~ /N$/;

				$self->{GROUPS}->{$db_version}->{G}->{$s_loc.$s_G_group}++;
				$self->{GROUPS}->{$db_version}->{g}->{$s_loc.$g_level_ars}++;
				$self->{GROUPS}->{$db_version}->{P}->{$s_loc.$p_level_ars}++;						

			}
		}
		print STDERR "Loading ARS File: $s_branch\n" if $self->{verbose};

	}

	
	

};

################################################################################################################
=head2 ac2gl

	Title:     ac2gl
	Usage:     ac2gl($loc,$typing)
	Function:  
	Returns:   allele list
	Args:      allele code

=cut
$ac2gl = sub{
	
	my $self   = shift();
	my $typing = shift();

	my($loc,$typ) = split(/\*/,$typing);
	$typ =~ s/$loc\*//;

	my $ua = new LWP::UserAgent;
    $ua->agent("AlleleCodeClient/0.1");
    my @allele_list_list;my @ret;

	my $url = $self->{acurl}."api/decode?typing=$loc*$typ";

    my $response = $ua->request(new HTTP::Request("GET", $url));
    my $code = $response->code;
    my $content = $response->content;
    my $headers = $response->headers_as_string;
    if ($code == 200) {  # OK
        #print STDERR "Request url:  $url\nStatus $code Content: \n$content\n"; 
        my @allele_list_list = split ("/", $content);
        push @ret, @allele_list_list;
    } elsif ($code == 400) { # Bad Request
        # Request syntax was bad, or the typing was bad
        # print error and keep original typing.
        print STDERR "Bad request: $content\n\turl:  $url\n";
        push @ret, ("$loc*$typ");
    } else {
        die "System error: code=$code $content\n";
    }

    return join("/",@ret);

};





1;
