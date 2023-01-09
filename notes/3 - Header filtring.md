# 3. Header filtring

In some cases, you can wish to filter headers which will be explained on this page.

```conf nginx.conf
http {
  js_path "/etc/nginx/njs/";

  js_import auth from http/header_filter.js;

  server {
      listen 80;

      location /secure/ {
          # Sending the auth request to internal /fetch_upstream
          auth_request /fetch_upstream;
          # Using the $sent_http variable instead of $upstream_http because js_header_filter use arbitrary header fields of a response header
          auth_request_set $backend $sent_http_x_backend;

          proxy_pass http://$backend;
      }

      location /fetch_upstream {
          internal;

          # Setting the "backend" based on token
          proxy_pass http://127.0.0.1:8079;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
          proxy_set_header X-Original-URI $request_uri;

          # Filtring setted backend
          js_header_filter auth.set_upstream;
      }
  }

  server {
      listen 127.0.0.1:8079;

      location / {
        js_content auth.choose_upstream;
      }
  }

  server {
      listen 127.0.0.1:8081;
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
    let args = qs.parse(r.headersIn['X-Original-URI'].split('?')[1]);

    switch (args.token) {
    // Setting backend to a name and not ip
    case 'A':
        r.headersOut['X-backend'] = 'B1';
        break;
    case 'B':
        r.headersOut['X-backend'] = 'B2';
        break;
    default:
        r.return(404);
    }

    r.return(200);
}

function set_upstream(r) {
    switch (r.headersOut['X-backend']) {
    // Filtring headers to ip based on name setted before
    case 'B1':
        r.headersOut['X-backend'] = '127.0.0.1:8081';
        break;
    case 'B2':
        r.headersOut['X-backend'] = '127.0.0.1:8082';
        break;
    }
}

export default { choose_upstream, set_upstream }
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
