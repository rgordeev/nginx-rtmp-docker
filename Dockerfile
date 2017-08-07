FROM 2chat/ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/nginx/sbin

# set up nginx and nginx-rtmp-module versions
ENV NGINX_VERSION 1.13.3
ENV NGINX_RTMP_VERSION 1.2.0

EXPOSE 8080
EXPOSE 1935

# create directories
RUN mkdir /src /config /logs /data /static

# install nginx dependencies
RUN apt-get install -y --no-install-recommends libpcre3-dev \
  zlib1g-dev libssl-dev wget && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /src
# get nginx source
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz \
# get nginx-rtmp module source
  && wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz \
  && tar zxf v${NGINX_RTMP_VERSION}.tar.gz \
  && rm v${NGINX_RTMP_VERSION}.tar.gz

# compile nginx with rtmp module
WORKDIR /src/nginx-${NGINX_VERSION}
RUN ./configure --with-http_ssl_module \
  --add-module=/src/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
  --with-http_stub_status_module \
 # set up nginx config directory 
  --conf-path=/config/nginx.conf \
 # set up nginx logs dirs
  --error-log-path=/logs/error.log \
  --http-log-path=/logs/access.log \
  && make \
  && make install

# install nginx config 
COPY nginx.conf /config/nginx.conf
# add stat.xsl for rtmp module
COPY static/* /static/

WORKDIR /
# launch nginx
CMD "nginx"