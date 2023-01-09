#!/usr/bin/env perl

use Crypt::JWT qw(decode_jwt encode_jwt);
use Data::Dumper;
use Try::Catch;
use Dancer2;

# set serializer => 'XML';
set serializer => 'JSON'; 
 
get '/' => sub{
    return {message => "First rest Web Service with Perl and Dancer"};
};

get '/accessToken' => sub {

    my $user = params->{name};

    my @recognized_users = ('Michael', 'Jim', 'Dwight');

    if ( ! grep( /^$user$/, @recognized_users ) ) {
        
        return {message => "Unable to validate user."};
    
    }
    print "madeit\n";
    my $secret_key = 'mysecretkey'; 
    my $relative_expiry = 10;
    my $expiry = time + $relative_expiry;

    my $token = encode_jwt(payload=>{data=>"any raw data $user", expiry=>$expiry}, key=>$secret_key, alg=>'HS256', relative_exp=>$relative_expiry);
    
    # sleep 13;

    # Make sure token isn't expired
    try {
        my $payload = decode_jwt(token=>$token, key=>$secret_key, verify_exp=>1);

        my %token_details = ( accessToken => $token, tokenExpiry=> $expiry);

        return \%token_details;

    }
    catch{
        return {message => "Hello $user\n Have a token: $token \n from user: FAIL"};

    }
    
};


get '/users/:name' => sub {
    my $user = params->{name};
    # return {"message" => "Hello $user"};
    return {message => "Hello $user"};
};
 
get '/users' => sub{
    my %users = (
        userA => {
            id   => "1",
            name => "Carlos",
        },
        userB => {
            id   => "2",
            name => "Andres",
        },
        userC => {
            id   => "3",
            name => "Bryan",
        },
    );

    return \%users;
};


dance;


