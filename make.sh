#!/bin/bash

####################### 
# READ ONLY VARIABLES #
#######################

readonly PROG_NAME=`basename "$0"`
readonly SCRIPT_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#################### 
# GLOBAL VARIABLES #
####################

########## 
# SOURCE #
##########
set -ex

rm -rf docs
mkdir docs
docker build -t presentations .
docker container rm -f presentation >/dev/null
docker run -d --entrypoint=/opt/revealjs/bin/present.py --name presentation presentations Training-for-Kubernetes 8080
# Selective copy to improve performace, takes forever if everything is copied
docker cp presentation:/opt/revealjs/dist   docs/dist
docker cp presentation:/opt/revealjs/images docs/images
docker cp presentation:/opt/revealjs/plugin docs/plugin
docker cp presentation:/opt/revealjs/src    docs/src

chmod -R 777 docs

for presentation in src/presentations/*; do
    echo "Begin: $(basename $presentation)"
    docker container rm -f presentation >/dev/null
    docker run -d -p 8080:8080 --entrypoint=/opt/revealjs/bin/present.py --name presentation presentations $(basename $presentation) 8080
    docker cp presentation:/opt/revealjs/index.html docs/$(basename $presentation).html
    docker run --rm --net=host -t -v $(pwd):/slides astefanutti/decktape:3.1.0 reveal --size=1920x1080 --pause 2000 --load-pause 2000 http://localhost:8080 docs/$(basename $presentation).pdf
    echo "End: $(basename $presentation)"
done

docker container rm -f presentation >/dev/null
docker run -d --entrypoint=/opt/revealjs/bin/present.py --name presentation presentations index 8080
docker cp presentation:/opt/revealjs/index.html docs/index.html
