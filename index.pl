#!/usr/bin/env perl

use JSON;
use Crypt::JWT qw(decode_jwt encode_jwt);
use Data::Dumper;
use Try::Catch;
use Dancer2;

# set serializer => 'XML';
set serializer => 'JSON'; 
set port => 3000;
set content_type => 'application/json';

# Token subs
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

sub createToken
{
    my $sub_payload = $_[0];

    my $secret_key = 'mysecretkey'; 
    my $relative_expiry = 30; # 1HR
    my $expiry = time + $relative_expiry;
    my $token = encode_jwt(payload=>{data=>"$sub_payload", expiry=>$expiry}, key=>$secret_key, alg=>'HS256', relative_exp=>$relative_expiry);
    return ( accessToken => $token, tokenExpiry=> $expiry);
}

sub validateAuthHeader
{
    my $request = $_[0];
    my $bearer_token = defined request->{env}->{HTTP_AUTHORIZATION} ? request->{env}->{HTTP_AUTHORIZATION} : ''; 
    $bearer_token =~ s/\s+Authorization\s//;
    $bearer_token = 'invalid' if $bearer_token eq '' || ( $bearer_token !~ m/Bearer/ );
    $bearer_token =~ s/\s?Bearer\s//;
    $bearer_token =~ s/\s+$//; # Right trim
    return $bearer_token;
}

# Request handling

# hook before => sub {
#     if (!session('user') && request->path !~ m{^/login}) {
#         forward '/login', { requested_path => request->path };
#     }
# };


get '/' => sub{
    return {message => "First rest Web Service with Perl and Dancer"};
};

# params->{name};
# query_parameters->get('user')
# body_parameters->get('user')

post '/accessToken' => sub {

    # print Dumper request;

    # Verify that Authorization Header was set and a token passed
    my $bearer_token = &validateAuthHeader(request);
    return {message => "Request failed", error=> "Missing/Invalid 'Authorization' Header"} if $bearer_token eq 'invalid';

    # Validate user
    my $user = body_parameters->get('name');
    my $pass = body_parameters->get('pass');

    my @recognized_users = ('Michael', 'Jim', 'Dwight');

    if ( ! grep( /^$user$/, @recognized_users ) || $pass ne 'password') {
        
        return {message => "Request failed", error=>"Unable to validate user"};
    
    }

    # Send token
    my %token_details = &createToken($user);
    return \%token_details;

    
};

get '/users' => sub{

    # Verify that Authorization Header was set and a token passed
    my $bearer_token = &validateAuthHeader(request);
    return {message => "Request failed", error=> "Missing/Invalid 'Authorization' Header"} if $bearer_token eq 'invalid';

    # Validate token/user
    my $username = &validateToken($bearer_token) || return {message => "The token you've provided has expired. Please request another."};

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


