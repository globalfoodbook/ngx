#!/bin/bash

# set -e
# set -x

export WP_HOST_IP=`awk 'NR==1 {print $1}' /etc/hosts`
export GFB_PIPED_DOMAINS=`echo ${SERVER_URLS}|awk '{gsub (" ", "\|",$0); print}'`

sudo cp ${USER_TEMPLATES_PATH}/configs/*.conf ${NGINX_USER_CONF_PATH}/configs;
sudo cp ${USER_TEMPLATES_PATH}/enabled/*.conf ${NGINX_USER_CONF_PATH}/enabled;
sudo cp ${USER_TEMPLATES_PATH}/conf/*.conf ${NGINX_CONF_PATH};
sudo cp ${USER_TEMPLATES_PATH}/lua/*.conf ${NGINX_USER_CONF_PATH}/lua;

for name in NGINX_USER NGINX_PATH_PREFIX SERVER_URLS MY_USER GFB_PIPED_DOMAINS LUA_ROOT_PATH LUAJIT_ROOT LUA_MAIN_VERSION SSL_ROOT NGINX_USER_CONF_PATH NGINX_CONF_PATH NGINX_LOG_PATH NGINX_USER_LOG_PATH VARNISH_PORT_80_TCP_ADDR VARNISH_PORT_80_TCP_PORT SWAG_PORT_80_TCP_ADDR SWAG_PORT_80_TCP_PORT LUAJIT_PACKAGE_PATH
do
    eval value=\$$name;
    sudo sed -i "s|\${${name}}|${value}|g" ${NGINX_CONF_PATH}/nginx.conf;
    sudo sed -i "s|\${${name}}|${value}|g" ${NGINX_USER_CONF_PATH}/lua/default.conf;
    sudo sed -i "s|\${${name}}|${value}|g" ${NGINX_USER_CONF_PATH}/configs/default.conf;
    sudo sed -i "s|\${${name}}|${value}|g" ${NGINX_USER_CONF_PATH}/enabled/80.conf;
    sudo sed -i "s|\${${name}}|${value}|g" ${NGINX_USER_CONF_PATH}/enabled/443.conf;
done

sudo ln -s ${NGINX_USER_CONF_PATH}/configs/${GFB_SCHEME}.conf ${NGINX_USER_CONF_PATH}/configs/scheme.conf

echo -e Environment variables setup completed;
sudo service nginx start > /dev/null 2>&1 &

echo -e Ngnix start up is complete;

sudo touch ${NGINX_USER_LOG_PATH}/access.log ${NGINX_USER_LOG_PATH}/error.log ${NGINX_LOG_PATH}/access.log ${NGINX_LOG_PATH}/error.log
sudo tail -F ${NGINX_USER_LOG_PATH}/access.log ${NGINX_USER_LOG_PATH}/error.log ${NGINX_LOG_PATH}/access.log ${NGINX_LOG_PATH}/error.log
