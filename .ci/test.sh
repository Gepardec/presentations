#!/bin/bash

source bashrc

set -e

docker-present-build

echo 1 | docker-present
sleep 5
docker container ls -a
docker-present-stop

docker-present-ansible-compatibility-testing
docker-present-stop ansible-compatibility-testing

docker-present-publish-revealjs

docker-present-publish ansible-compatibility-testing

set +e