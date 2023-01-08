# Test dockerfile for module testing
# Starting with a ubuntu base
FROM ubuntu

# Installing njs, nginx and nano to easily modify the configutation
RUN apt update
RUN apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
RUN apt update
RUN apt install -y nginx-module-njs
RUN apt install nano

# Update config file
RUN printf "load_module modules/ngx_http_js_module.so;\n\nevents {}\n\nhttp {}" > etc/nginx/nginx.conf

# BUILD
# docker build -t nmmtest .
