# PerlRestAPI
Using Dancer to build a basic REST API with JWT Auth

### Get an access/refresh token pair from user/pass
access expires after 10s/refresh expires after 10m 

Make POST request to: `http://<host>:3000/accessToken`
#### Headers:  
- Content-Type: application/json

#### Post Body
`
{
    "username":"dwight",
    "password":"bearsbeets"
}
`
<- That's the only valid user at the moment - tweak to your needs.

#### Reponse
`
{
    "accessToken": <token>,
    "accessTokenExpiry": <epoch>,
    "refreshToken": <token>,
    "refreshTokenExpiry": <epoch>
}
`
### Get an access/refresh token pair from refreshToken
access expires after 10s/refresh expires after 10m 

#### Headers:
- Content-Type: application/json
- Authorization: Bearer <refreshToken>

Not payload required.

#### Reponse
`
{
    "accessToken": <token>,
    "accessTokenExpiry": <epoch>,
    "refreshToken": <token>,
    "refreshTokenExpiry": <epoch>
}
`

### Get users
Make GET request to `http://<host>:3000/users`

#### Headers:
- Content-Type: application/json
- Authorization: Bearer <token>

Note: Obviously accessToken wouldn't expire after 10s (nor serving on port 3000) - but this is a template to lay the groundwork for a RESTful service with Dancer.
Also, we're only manually validating one user when we really should be validating against a database.





