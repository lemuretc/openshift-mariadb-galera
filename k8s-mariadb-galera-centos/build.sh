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
	echo "No tag specified, can determine automatic, use eg. build.sh 10.1.21"
	exit 1
	TAG=$($YUM info MariaDB-server|grep '^Version'|tail -1|cut -b 15- || echo -n "7.0")
}
echo -e "\nbuilding $REPO/$IMAGE:$TAG\n"

# check if any packages have updates and update timestamp in Dockerfile to force update
#$YUM check-update || \
{
	sed -i "s/#DATE:.*/#DATE: $(LANG=C date)/" Dockerfile
	# pull newer image, to get a small as possible images
	docker pull centos:7
}

# repo build
docker build -t $REPO/$IMAGE:$TAG .
docker tag $REPO/$IMAGE:$TAG $REPO/$IMAGE:latest
docker push $REPO/$IMAGE:$TAG
docker push $REPO/$IMAGE:latest
