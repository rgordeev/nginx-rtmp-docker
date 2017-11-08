FROM alpine:3.6

MAINTAINER Roman Gordeev <roma.gordeev@gmail.com>

# set up nginx and nginx-rtmp-module versions
ENV NGINX_VERSION 1.13.3
ENV NGINX_RTMP_VERSION 1.2.0

# create required directories
RUN mkdir /src /data /static

# install base nginx dependencies openssl-dev pcre-dev zlib-dev wget build-base
RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base

# set /src as current directory
WORKDIR /src
# get nginx source
RUN set -x \ 
  && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz \
# get nginx-rtmp module source
  && wget --no-check-certificate https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz \
  && tar zxf v${NGINX_RTMP_VERSION}.tar.gz \
  && rm v${NGINX_RTMP_VERSION}.tar.gz

# compile nginx with rtmp module
WORKDIR /src/nginx-${NGINX_VERSION}
RUN set -x \
  && ./configure \
# add modules to build with
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --add-module=/src/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
# set up base path for nginx installation and logs
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx \
  && make \
  && make install \
# clean up after build
  && apk del build-base \
  && rm -rf /tmp/src \
  && rm -rf /var/cache/apk/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# install nginx config 
COPY nginx.conf /etc/nginx/conf/nginx.conf
# add stat.xsl for rtmp module
COPY static/* /static/

VOLUME ["/var/log/nginx"]
VOLUME ["/data"]

WORKDIR /etc/nginx

EXPOSE 8080
EXPOSE 1935

CMD ["nginx", "-g", "daemon off;"]
