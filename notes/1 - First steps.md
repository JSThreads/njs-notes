# 1. First steps

To start with njs, we are going to do a simple http response. For this we need to configure the `/etc/nginx/nginx.conf` file and create our Javascript file.

```conf nginx.conf
# Configuration file for Nginx

# Load the njs module
load_module modules/ngx_http_js_module.so;

events {}
http {
  # Set the default path of njs modules
  js_path "/etc/nginx/njs/";
  
  # Importing the module
  # The http/ is used because the hello.js has the js_path as the default and the file location is /etc/nginx/njs/http/
  # Renaming the import because of the subdirectory
  js_import main from http/hello.js
  
  server {
    listen 80;
    
    location /hello {
      # We use the hello function from main which points to http/hello.js
      js_content main.hello;
    }
    location /version {
      # Same as for the /hello location
      js_content main.version;
    }
  }
}
```

```js hello.js
// We create a function which took the request as the argument
function hello(r) {
    // The request returns the response status and optionnaly a body
    r.return(200, "Hello world!\n");
}
function version(r) {
    // Here we use a njs variable
    r.return(200, njs.version);
}

// don't forget to export the functions
export default { hello, version }
```

## Tests

```
~ /   curl localhost/hello
Hello world!

~ /   curl locahost/version
0.7.9
~ /
```
