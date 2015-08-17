#!/usr/bin/env perl
use Dancer;
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
        
       $tokens->{'css_url'}    = request->base . 'css/style.css';
       $tokens->{'login_url'}  = uri_for('/login');
       $tokens->{'logout_url'} = uri_for('/logout');
       $tokens->{'upload_url'} = uri_for('/upload');
       $tokens->{'ars_redux_url'} = uri_for('/redux');
       $tokens->{'ars_reduxfile_url'} = uri_for('/reduxfile');
};

start;
