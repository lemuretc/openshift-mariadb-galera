#!/bin/bash -x
################################################################################
###
###  build-script for galera container
###
###  Author:  Ralf Becker <rb@egroupware.org>
###
################################################################################

# change to directory for this script, as docker build requires that
cd $(dirname $0)

# use quay.io egroupware registry
REPO=quay.io/egroupware
IMAGE=galera
# yum does NOT work, as Dockerfile sets USER 27
YUM="docker run --rm --entrypoint /usr/bin/yum $REPO/$IMAGE"
test -z "${TAG:=$1}" && {
	TAG=$(curl https://yum.mariadb.org/10.1/centos7-amd64/rpms/ 2>/dev/null|grep centos73-x86_64-server.rpm|sed -E 's/^.*MariaDB-(10.1.[0-9]+)-centos73-x86_64-server.rpm.*$/\1/g'|sort|tail -1)
}
echo -e "\nbuilding $REPO/$IMAGE:$TAG\n"

# check if any packages have updates and update timestamp in Dockerfile to force update
#$YUM check-update || \
{
	sed -i "" "s/#Date:.*/#Date: $(LANG=C date)/" Dockerfile
	# pull newer image, to get a small as possible images
	docker pull centos:7
}

# repo build
docker build --no-cache -t $REPO/$IMAGE:$TAG .
docker tag $REPO/$IMAGE:$TAG $REPO/$IMAGE:latest
docker push $REPO/$IMAGE:$TAG
docker push $REPO/$IMAGE:latest
