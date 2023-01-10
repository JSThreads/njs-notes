# 4. JWT Authorization fetching data from header

This module is decrypting data from in header data.

```conf nginx.conf
...

http {
  js_path "/etc/nginx/njs/";

  js_import jwt from jwt/decode.js;
  # We set the jwt_payload_sub function from jwt to the $jwt_payload_sub
  js_set $jwt_payload_sub jwt.jwt_payload_sub;

  server {
    location /jwt {
      return 200 $jwt_payload_sub;
    }
  }
}
```

```js decode.js
function jwt(data) {
    // decrypting the header
    var parts = data.split('.').slice(0,2)
        .map(v=>Buffer.from(v, 'base64url').toString())
        .map(JSON.parse);
    // returning decrypted datas
    return { headers:parts[0], payload: parts[1] };
}

function jwt_payload_sub(r) {
    // responding with the payload decrypted from the header
    return JSON.stringify(jwt(r.headersIn.Authorization.slice(7)).payload);
}

export default { jwt_payload_sub }
```

## Tests

```
~ /   curl 'http://localhost/jwt' -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImV4cCI6MTU4NDcyMzA4NX0.eyJpc3MiOiJuZ2lueCIsInN1YiI6ImFsaWNlIiwiZm9vIjoxMjMsImJhciI6InFxIiwienl4IjpmYWxzZX0.Kftl23Rvv9dIso1RuZ8uHaJ83BkKmMtTwch09rJtwgk"
{"iss":"nginx","sub":"alice","foo":123,"bar":"qq","zyx":false}
```
