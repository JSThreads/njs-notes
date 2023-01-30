<h1 align=center>Njs notes</h1>

![njsbannerwithbg](https://user-images.githubusercontent.com/73474137/211214634-324602dc-f9f3-47ad-8435-2723a17a9548.png)

<p align=center><i>~ Notes for njs and Nginx modules development in Js</i></p>

## Introduction

Nginx modules can be written in multiple languages like **C**, **Perl**, **Lua** or ***Js*** with *Njs*. Because of a compiler written by the team of Nginx you **shouldn't use it for big calculus or cryptography**.

## Installation

You can install **njs** with the next commands for ubuntu:

```sh
# To run in admin mode or with sudo
apt update

apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
apt update
apt install -y nginx-module-njs
```

Finally you have to add the next line to `/etc/nginx/nginx.conf` and start nginx:

```
load_module modules/ngx_http_js_module.so;
```

```sh
# To run in admin mode or with sudo
service nginx start
```

**🐳 ~ For testing, you can use a Docker image that I have created for this.**

## Pages

1. [First steps](https://github.com/PovaJS/njs-notes/blob/main/notes/1%20-%20First%20steps.md)
2. [Simple auth](https://github.com/PovaJS/njs-notes/blob/main/notes/2%20-%20Simple%20auth.md)
3. [Header filtring](https://github.com/PovaJS/njs-notes/blob/main/notes/3%20-%20Header%20filtring.md)
4. [JWT fetching data from header](https://github.com/PovaJS/njs-notes/blob/main/notes/4%20-%20JWT%20fetching%20data%20from%20header.md)
