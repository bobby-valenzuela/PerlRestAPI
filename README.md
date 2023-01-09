# PerlRestAPI
Using Dancer to build a basic REST API with JWT Auth

### Get an access token (expires after 10s)
Only reconized users are "Dwight", "Michael", and "Jim".
Make GET request to: `http://<host>:3000/accessToken?name=<username>`

Note: Obviously we wouldn't be using a username or even a GET request to get an access token and the token wouldn't expire after 10s (nor serving on port 3000) - but this is a template to lay the groupdwork for a RESTful service with Dancer.
