#!/bin/bash

# Make sure to start boot2docker before running this script
eval "$(docker-machine env default)"

/usr/local/bin/docker login

read -p "What version number or tag are you deploying? " tag

if [[ $tag ]]; then
  /usr/local/bin/docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=`git rev-parse --short HEAD` -t globalfoodbook/ngxl:$tag .
  /usr/local/bin/docker push globalfoodbook/ngxl:$tag

  /usr/local/bin/docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=`git rev-parse --short HEAD` -t globalfoodbook/ngxl:latest .
  /usr/local/bin/docker push globalfoodbook/ngxl:latest
else
  echo -e "Kindly provide a tag or version number"
fi
