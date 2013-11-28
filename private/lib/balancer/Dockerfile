FROM ubuntu:12.04
MAINTAINER Everton Ribeiro <everton@azukiapp.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# Install
RUN apt-get update
RUN apt-get install -y wget

RUN wget -q -O - http://apt.hellobits.com/hellobits.key | apt-key add -
RUN echo 'deb http://apt.hellobits.com/ precise main' > /etc/apt/sources.list.d/hellobits.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise universe' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y nginx-plus redis-server git-core

# nginx
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./nginx/nginx_azk.conf /azk/nginx/nginx_azk.conf
ADD ./nginx/access_hipache.lua /azk/nginx/access_hipache.lua
ADD ./nginx/header_hipache.lua /azk/nginx/header_hipache.lua

RUN mkdir -p /azk/nginx
RUN git clone https://github.com/agentzh/lua-resty-redis /azk/nginx/lua-resty-redis
RUN git --git-dir=/azk/nginx/lua-resty-redis/.git checkout v0.16

# redis
RUN sed -i -e"s/^bind 127.0.0.1/bind 0.0.0.0/" /etc/redis/redis.conf

# Start script
ADD ./services.sh /azk/services.sh
RUN chmod 755 /azk/services.sh

# private expose
EXPOSE 80
EXPOSE 6379

CMD ["/bin/bash", "/azk/services.sh"]
