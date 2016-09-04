# Start with a base Ubuntu 14:04 image
FROM ubuntu:trusty

MAINTAINER Ikenna N. Okpala <me@ikennaokpala.com>
ARG BUILD_DATE
ARG VCS_REF
# i.e
# BUILD_DATE `date -u +"%Y-%m-%dT%H:%M:%SZ"`
# VCS_REF `git rev-parse --short HEAD`
LABEL org.label-schema.build-date=$BUILD_DATE \
       org.label-schema.docker.dockerfile="/Dockerfile" \
       org.label-schema.license="GNU GENERAL PUBLIC LICENSE" \
       org.label-schema.name="NGINX-LUA docker container (gfb)" \
       org.label-schema.url="http://globalfoodbook.com/" \
       org.label-schema.vcs-ref=$VCS_REF \
       org.label-schema.vcs-type="Git" \
       org.label-schema.vcs-url="https://github.com/globalfoodbook/ngxl.git"

# Set up user environment

# Two users are defined one created by nginx and the other the host. This is for security reason www-data is configure accordingly with login disabled:
# sudo adduser --system --no-create-home --user-group --disabled-login --disabled-password www-data
#sudo adduser --system --no-create-home --user-group -s /sbin/nologin www-data

# Check before upgrade lua here https://github.com/openresty/lua-nginx-module#installation

ENV MY_USER=gfb WEB_USER=www-data DEBIAN_FRONTEND=noninteractive GFB_SCHEME=https SERVER_URLS="globalfoodbook.com www.globalfoodbook.com globalfoodbook.net www.globalfoodbook.net globalfoodbook.org www.globalfoodbook.org globalfoodbook.co.uk www.globalfoodbook.co.uk" LOCAL_HOST_IP=0.0.0.0 LANG=en_US.UTF-8 LANGUAGE=en_US.en LC_ALL=en_US.UTF-8 NGINX_VERSION=1.9.15 OPENRESTY_VERSION=1.9.15.1  OPENRESTY_PATH=/etc/openresty LUAROCKS_VERSION=2.3.0 LUA_MAIN_VERSION=5.1 RESTY_AUTO_SSL_PATH=/etc/resty-auto-ssl OPENSSL_VERSION=1.0.2h SSL_ROOT=/etc/ssl LUAJIT_VERSION=2.1 LUA_SUFFIX=jit-2.1.0-beta2

ENV OPENRESTY_PATH_PREFIX=${OPENRESTY_PATH}/ngxl NGINX_USER=${MY_USER} HOME=/home/${MY_USER}
ENV NGINX_PATH_PREFIX=${OPENRESTY_PATH_PREFIX}/nginx
ENV LUAJIT_ROOT=${OPENRESTY_PATH_PREFIX}/luajit NGINX_LOG_PATH=${NGINX_PATH_PREFIX}/logs NGINX_CONF_PATH=${NGINX_PATH_PREFIX}/conf USER_TEMPLATES_PATH=${HOME}/templates
ENV NGINX_USER_CONF_PATH=${NGINX_CONF_PATH}/${MY_USER} OPENSSL_ROOT=${NGINX_PATH_PREFIX}/openssl-${OPENSSL_VERSION} NGINX_USER_LOG_PATH=${NGINX_LOG_PATH}/${MY_USER} PATH="${PATH}:${OPENRESTY_PATH}/bin:${NGINX_PATH_PREFIX}/sbin:${NGINX_PATH_PREFIX}/bin:${LUAJIT_ROOT}/bin" LUAJIT_PACKAGE_PATH=${LUAJIT_ROOT}/share/lua/${LUA_MAIN_VERSION}

ENV NGINX_FLAGS="--with-file-aio --with-ipv6 --with-http_ssl_module  --with-luajit-xcflags=-DLUAJIT_ENABLE_LUA52COMPAT --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-http_perl_module --with-mail --with-mail_ssl_module --with-pcre --with-google_perftools_module --with-debug --with-openssl=${OPENSSL_ROOT} --with-md5=${OPENSSL_ROOT} --with-md5-asm --with-sha1=${OPENSSL_ROOT}" PS_NGX_EXTRA_FLAGS="--with-cc=/usr/bin/gcc --with-ld-opt=-static-libstdc++"

RUN adduser --disabled-password --gecos "" $MY_USER && echo "$MY_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $MY_USER

# Add all base dependencies
RUN sudo apt-get update -y && sudo apt-get install -y build-essential \
  checkinstall language-pack-en-base musl-dev \
  vim curl tmux wget unzip libnotify-dev imagemagick libmagickwand-dev \
  libfuse-dev libcurl4-openssl-dev mime-support automake libtool \
  python-docutils libreadline-dev libxslt1-dev libgd2-xpm-dev libgeoip-dev \
  libgoogle-perftools-dev libperl-dev pkg-config libssl-dev git-core \
  libgmp-dev zlib1g-dev libxslt-dev libxml2-dev libpcre3 libpcre3-dev \
  freetds-dev openjdk-7-jdk software-properties-common libstdc++-4.8-dev \
  && sudo mkdir -p ${OPENSSL_ROOT} ${NGINX_USER_CONF_PATH}/enabled ${NGINX_USER_CONF_PATH}/configs ${NGINX_USER_CONF_PATH}/lua ${USER_TEMPLATES_PATH}/enabled ${USER_TEMPLATES_PATH}/configs ${USER_TEMPLATES_PATH}/conf ${USER_TEMPLATES_PATH}/lua ${NGX_PAGESPEED_PATH} ${NGINX_LOG_PATH} ${NGINX_USER_LOG_PATH}

ADD templates/nginx/init.sh /etc/init.d/nginx
ADD templates/entrypoint.sh /etc/entrypoint.sh

RUN /bin/bash -l -c "sudo wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz -O ${NGINX_PATH_PREFIX}/openssl-${OPENSSL_VERSION}.tar.gz && sudo tar -xzvf ${NGINX_PATH_PREFIX}/openssl-${OPENSSL_VERSION}.tar.gz -C ${NGINX_PATH_PREFIX}/" \
  && /bin/bash -l -c "sudo wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz -O /etc/openresty-${OPENRESTY_VERSION}.tar.gz && sudo tar -xzvf /etc/openresty-${OPENRESTY_VERSION}.tar.gz -C /etc && cd /etc/openresty-${OPENRESTY_VERSION} && sudo ./configure --prefix=${OPENRESTY_PATH_PREFIX} ${PS_NGX_EXTRA_FLAGS} ${NGINX_FLAGS} && sudo make && sudo make install && sudo ln -sf ${LUAJIT_ROOT}/bin/${LUA_SUFFIX} ${LUAJIT_ROOT}/bin/lua && sudo ln -sf ${LUAJIT_ROOT}/bin/lua /usr/local/bin/lua" \
  && /bin/bash -l -c "sudo wget https://github.com/keplerproject/luarocks/archive/v${LUAROCKS_VERSION}.tar.gz -O ${OPENRESTY_PATH}/v${LUAROCKS_VERSION}.tar.gz && sudo tar -xzvf ${OPENRESTY_PATH}/v${LUAROCKS_VERSION}.tar.gz -C ${OPENRESTY_PATH} && cd ${OPENRESTY_PATH}/luarocks-${LUAROCKS_VERSION} && sudo ./configure --prefix=${LUAJIT_ROOT} --with-lua=${LUAJIT_ROOT} --lua-suffix=${LUA_SUFFIX} --sysconfdir=${LUAJIT_ROOT}/luarocks --with-lua-lib=${LUAJIT_ROOT}/lib --with-lua-include=${LUAJIT_ROOT}/include/luajit-${LUAJIT_VERSION} --force-config && sudo make build && sudo make install && sudo ${LUAJIT_ROOT}/bin/luarocks install lua-resty-auto-ssl && sudo mkdir -p ${RESTY_AUTO_SSL_PATH} && sudo chown -R ${NGINX_USER}:${NGINX_USER} ${RESTY_AUTO_SSL_PATH} && sudo chown -R ${NGINX_USER}:${NGINX_USER} ${OPENRESTY_PATH} && sudo rm -rf ${OPENRESTY_PATH}/*.zip  ${OPENRESTY_PATH}/*.tar.gz ${NGINX_CONF_PATH}/*.tar.gz ${NGINX_CONF_PATH}/*.zip ${NGINX_USER_CONF_PATH}/*.tar.gz ${NGINX_USER_CONF_PATH}/*.zip ${OPENRESTY_PATH}/luarocks-${LUAROCKS_VERSION} /etc/openresty-*" \
  # && sudo sed -i s"/if exit_code == 0 then/if exit_code == 0 or exit_code == true then/" "${LUAJIT_PACKAGE_PATH}/resty/auto-ssl/utils/start_sockproc.lua" \
  && sudo openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
  -subj '/CN=sni-support-required-for-valid-ssl' \
  -keyout ${SSL_ROOT}/resty-auto-ssl-fallback.key \
  -out ${SSL_ROOT}/resty-auto-ssl-fallback.crt \
  && sudo cp ${NGINX_CONF_PATH}/nginx.conf ${NGINX_CONF_PATH}/nginx.conf.default \
  && /bin/bash -l -c "sudo chmod +x /etc/init.d/nginx && sudo update-rc.d nginx defaults" \
  && /bin/bash -l -c "sudo echo 'Europe/London' | sudo tee /etc/timezone && sudo dpkg-reconfigure --frontend $DEBIAN_FRONTEND tzdata" \
  && sudo chmod +x /etc/entrypoint.sh

ADD templates/nginx/conf/*.conf ${USER_TEMPLATES_PATH}/conf/
ADD templates/nginx/enabled/*.conf ${USER_TEMPLATES_PATH}/enabled/
ADD templates/nginx/configs/*.conf ${USER_TEMPLATES_PATH}/configs/
ADD templates/nginx/lua/* ${USER_TEMPLATES_PATH}/lua/

WORKDIR ~/

EXPOSE 80
EXPOSE 443

# Setup the entrypoint
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/etc/entrypoint.sh"]
