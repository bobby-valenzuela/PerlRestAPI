# PerlRestAPI
Using Dancer to build a basic REST API with JWT Auth

### Get an access token (expires after 10s)
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
^ That's the only valid user at the moment - tweak to your needs.

#### Reponse
`
{
    "accessToken": <token>,
    "tokenExpiry": <epoch>
}
`



### Get users
Make GET request to `http://<host>:3000/users`

#### Headers:
- Content-Type: application/json
- Authorization: Bearer <token>

Note: Obviously token wouldn't expire after 10s (nor serving on port 3000) - but this is a template to lay the groupdwork for a RESTful service with Dancer.





