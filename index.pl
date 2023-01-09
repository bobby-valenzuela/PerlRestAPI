#!/usr/bin/env perl

use Crypt::JWT qw(decode_jwt encode_jwt);
use Data::Dumper;
use Try::Catch;
use Dancer2;

# set serializer => 'XML';
set serializer => 'JSON'; 

sub validateToken
{
    my $sub_token = $_[0];

    my $secret_key = 'mysecretkey'; 

    try {
        my $payload = decode_jwt(token=>$sub_token, key=>$secret_key, verify_exp=>1);

        return 0 if ( $payload->{expiry} <= time);
        
        return $payload->{data};


    }
    catch{ return 0; }

}

get '/' => sub{
    return {message => "First rest Web Service with Perl and Dancer"};
};

get '/accessToken' => sub {

    my $user = params->{name};

    my @recognized_users = ('Michael', 'Jim', 'Dwight');

    if ( ! grep( /^$user$/, @recognized_users ) ) {
        
        return {message => "Unable to validate user."};
    
    }

    my $secret_key = 'mysecretkey'; 
    my $relative_expiry = 30;
    my $expiry = time + $relative_expiry;

    my $token = encode_jwt(payload=>{data=>"$user", expiry=>$expiry}, key=>$secret_key, alg=>'HS256', relative_exp=>$relative_expiry);

    my %token_details = ( accessToken => $token, tokenExpiry=> $expiry);

    return \%token_details;

    
};

get '/users' => sub{

    my $token = params->{token};
    my $username = &validateToken($token) || return {message => "The token you've provided has expired. Please request another."};

    my %users = (
        RegionalManager => {
            id   => "1",
            name => "M.Scott",
        },
        NumberTwo => {
            id   => "2",
            name => "J.Halpert",
        },
        BeetFarmer => {
            id   => "3",
            name => "D.Schrute",
        },
    );

    return \%users;
};


# get '/users/:name' => sub {
#     my $user = params->{name};
#     return {message => "Hello $user"};
# };
 

dance;


