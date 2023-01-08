# 2. Simple auth

To do this simple auth we will use the nginx **http auth request** module.  

```conf nginx.conf
...

http {
  js_path "/etc/nginx/njs/";

  js_import auth from http/auth_request.js;

  server {
      listen 80;

      # Use the /secure path to do the request
      location /secure {
          # Sending the auth request to /fetch_upstream
          auth_request /fetch_upstream;
          # Getting the server ip from header variable with the next syntax: $upstream_http_* where the * is the header variable
          auth_request_set $backend $upstream_http_x_backend;

          # Use the variable getted before to redirect the content
          proxy_pass http://$backend;
      }

      location /fetch_upstream {
          # It's not accessible outside Nginx
          internal;

          # Passing only the URI to resolve
          proxy_pass http://127.0.0.1:8079;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
          proxy_set_header X-Original-URI $request_uri;
      }
  }

  server {
      listen 127.0.0.1:8079;

      location / {
        # Using the choose_upstream function to resolve the URI
        js_content auth.choose_upstream;
      }
  }

  server {
      listen 127.0.0.1:8081;
      
      # Using the URI variable which is the current URI processing by Nginx with the response status code
      return 200 "BACKEND A:$uri\n";
  }

  server {
      listen 127.0.0.1:8082;
      return 200 "BACKEND B:$uri\n";
  }
}
```

```js auth_request.js
import qs from "querystring";

function choose_upstream(r) {
    // We parse arguments from URI
    let args = qs.parse(r.headersIn['X-Original-URI'].split('?')[1]);

    switch (args.token) {
    // We set the backend to the right token
    case 'A':
        r.headersOut['X-backend'] = '127.0.0.1:8081';
        break;
    case 'B':
        r.headersOut['X-backend'] = '127.0.0.1:8082';
        break;
    default:
        // If any token worked return 404 error
        // A internal error will be displayed because any backend is set
        r.return(404);
    }

    // return success if the token was right
    r.return(200);
}

export default { choose_upstream }
```

## Tests

```
~ /   curl localhost/secure/any/uri?token=B
BACKEND B:/secure/any/uri

~ /   curl localhost/secure/for/a/too?token=A
BACKEND A:/secure/for/a/too

~ /   curl localhost/secure/error?token=invalid
<html>
<head><title>500 Internal Server Error</title></head>
<body>
<center><h1>500 Internal Server Error</h1></center>
<hr><center>nginx/1.22.1</center>
</body>
</html>

~ /
```
