# 5. Generation of JWT tokens

To generate JWT tokens we need to set an environment variable with the key to generate unique keys. We can do it in the terminal with the next command:

```sh
JWT_GEN_KEY="My_secret_KeY"
export JWT_GEN_KEY
```

You can test it by running:

```sh
printenv JWT_GEN_KEY
```

Here you have the Nginx config and the njs module:

```conf
...

# Secret key to generate token
env JWT_GEN_KEY;

http {
    js_path "/etc/nginx/njs/";

    js_import jwt from jwt/key_generator.js;
    js_set $jwt jwt.gen_token;

    server {
        location /jwt {
            return 200 $jwt;
        }
    }
}
```

```js
async function generation(initClaims, key, valid) {
    let header = { typ: "JWT", alg: "HS256" };
    let claims = Object.assign(initClaims, { exp: Math.floor(Date.now() / 1000) + valid });

    let s = [header, claims].map(JSON.stringify)
    .map(v => Buffer.from(v).toString('base64url'))
    .join('.');

    let wc_key = await crypto.subtle.importKey('raw', key, { name: 'HMAC', hash: 'SHA-256' }, false, [ 'sign' ]);
    let sign = await crypto.subtle.sign({ name: 'HMAC' }, wc_key, s);

    return s + '.' + Buffer.from(sign).toString('base64url');
}

async function gen_token(r) {
    let claims = {
        somevalue: "content",
        message: "here",
        number: 123
    };


    let token = await generation(claims, process.env.JWT_GEN_KEY, 600)
    r.setReturnValue(token);
}

export default { gen_token }
```

## Tests

```
~ /   curl localhost/jwt
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzb21ldmFsdWUiOiJjb250ZW50IiwibWVzc2FnZSI6ImhlcmUiLCJudW1iZXIiOjEyMywiZXhwIjoxNjc1MjEwNTk1fQ.-pprK22CIDLxnQw1C1hPBehSU2tmUGghIYiJzaziYrU
```

> https://www.nginx.com/blog/securing-urls-secure-link-module-nginx-plus/
