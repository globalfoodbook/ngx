# A NGINX-LUA docker image.

A Docker container for setting up programmable Nginx instance.

This server serves requests from client web browser via port 80. This best suites development purposes.

This is a sample Nginx-Lua docker container used to test Wordpress installation on [http://globalfoodbook.com](http://globalfoodbook.com)


To build this ngxl server run the following command:

```bash
$ docker pull globalfoodbook/ngxl
```

This will run on a default port of 80.

To change the PORT for this run the following command:

```bash
$ docker run --name=ngxl --detach=true --publish=80:80  --publish=443:443 --link=varnish:varnish
```

To run the server and expose it on port 80 of the host machine, run the following command:

```bash
$ docker run --name=ngxl --detach=true --publish=80:80  --publish=443:443 --link=varnish:varnish globalfoodbook/ngxl
```

To run the server in interactive mode of the host machine, run the following command:

```bash
$ docker run --name=ngxl -it --publish=80:80  --publish=443:443 --link=varnish:varnish globalfoodbook/ngxl /bin/bash
```

# NB:

## Before pushing to docker hub

## Login

```bash
$ docker login
```

## Build

```bash
$ cd /to/docker/directory/path/
$ docker build -t <username>/<repo>:latest .
```

## Push to docker hub

```bash
$ docker push <username>/<repo>:latest
```


IP=`docker inspect ngxl | grep -w "IPAddress" | awk '{ print $2 }' | head -n 1 | cut -d "," -f1 | sed "s/\"//g"`
HOST_IP=`/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

DOCKER_HOST_IP=`awk 'NR==1 {print $1}' /etc/hosts` # from inside a docker container

# Contributors

* [Ikenna N. Okpala](http://ikennaokpala.com)
