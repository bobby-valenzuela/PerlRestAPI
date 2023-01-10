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

# Request handling

# hook before => sub {
#     if (!session('user')  request->path !~ m{^/login}) {
#         forward '/login', { requested_path => request->path };
#     }
# };

get '/' => sub{
    return {message => "Sample REST API"};
};

# params->{name};
# query_parameters->get('user')
# body_parameters->get('user')

post '/accessToken' => sub {

    # print Dumper request;

    # Verify Content-Type
    return sendErrResponse('Content-Type') if ! validateHeader(request,'Content-Type');

    # Validate user
    my $username = body_parameters->get('username');
    my $password = body_parameters->get('password');

    if ($username ne '' && $password ne ''){

        if ($username eq lc('dwight') && $password eq 'bearsbeets'){

            # Send token info
            my %token_details = createToken($username);
            return \%token_details;

        }else{

            return {message => "Request failed", error=>"Unable to validate user"};
        
        }

    }
    else{
        
        return {message => "Request failed", error=>"Missing username/password properties"};

    }

};

get '/users' => sub{

    # Verify Content-Type
    return sendErrResponse('Content-Type') if ! validateHeader(request,'Content-Type');
    return sendErrResponse('Authorization') if ! validateHeader(request,'Authorization');

    # Validate token/user
    my $username = validateToken(validateHeader(request,'Authorization')) || return {message => "The token you've provided has expired. Please request another."};

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

sub validateHeader
{
    my $request = $_[0];
    my $header = $_[1];

    if ($header eq 'Authorization'){

        my $bearer_token = defined request->{env}->{HTTP_AUTHORIZATION} ? request->{env}->{HTTP_AUTHORIZATION} : ''; 
        $bearer_token =~ s/\s+Authorization\s//;
        $bearer_token = 'invalid' if $bearer_token eq '' || ( $bearer_token !~ m/Bearer/ );
        $bearer_token =~ s/\s?Bearer\s//;
        $bearer_token =~ s/\s+$//; # Right trim
        $bearer_token = 0 if $bearer_token eq 'invalid';
        return $bearer_token;

    }
    elsif ($header eq 'Content-Type'){

        my $content_type = defined request->{env}->{CONTENT_TYPE} ? request->{env}->{CONTENT_TYPE} : ''; 
        $content_type =~ s/\s//g;
        return lc($content_type) eq 'application/json' ? 1 : 0;
    }
}

sub sendErrResponse
{
    my $response_type = $_[0];

    return {message => "Request failed", error=> "Missing/Invalid 'Content-Type' Header. Expected 'application/json'"} if $response_type eq 'Content-Type';
    return {message => "Request failed", error=> "Missing/Invalid 'Authorization' Header"} if $response_type eq 'Authorization';

}

dance;


