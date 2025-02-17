#!/bin/bash
#
# Adfinis SyGroup AG
# openshift-mariadb-galera: Container entrypoint
#

set -e
set -x

# Locations
CONTAINER_SCRIPTS_DIR="/usr/share/container-scripts/mysql"
EXTRA_DEFAULTS_FILE="/etc/my.cnf.d/galera.cnf"

#Start tcp server, send current pod IP address 
#The this is used to find Peers across clusters via the sumariner exposed services
socat -vv tcp4-listen:4455,fork system:"echo $(hostname -i)" &

# Check if the container runs in Kubernetes/OpenShift
if [ -z "$POD_NAMESPACE" ]; then
	# Single container runs in docker
	echo "POD_NAMESPACE not set, spin up single node"
	cp ${CONTAINER_SCRIPTS_DIR}/galera.cnf ${EXTRA_DEFAULTS_FILE}
else
	# Is running in Kubernetes/OpenShift, so find all other pods
	# belonging to the namespace
	echo "Galera: Finding peers"
	K8S_SVC_NAME=$(hostname -f | cut -d"." -f2)
	echo "Using service name: ${K8S_SVC_NAME}"
	cp ${CONTAINER_SCRIPTS_DIR}/galera.cnf ${EXTRA_DEFAULTS_FILE}
	
	#Peer finder not working yet
	#/usr/bin/peer-finder -on-start="${CONTAINER_SCRIPTS_DIR}/configure-galera.sh" -service=${K8S_SVC_NAME}
	#Direct call instead
	#source the script so we can read IPs
	. ${CONTAINER_SCRIPTS_DIR}/configure-galera.sh
fi

# We assume that mysql needs to be setup if this directory is not present
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Configure first time mysql"
	${CONTAINER_SCRIPTS_DIR}/configure-mysql.sh
fi

if [ $LEADER_IP == $(hostname -i) ]; then
	# Run mysqld as a leader
	exec mysqld --wsrep-new-cluster
else
	# Run mysqld
	exec mysqld --server-id=${SERVER_ID_BASE:-1} \
		--gtid-domain-id=$((${GTID_DOMAIN_ID_BASE:-0} + $(echo $HOSTNAME | grep -e '^mysql-[0-9]$' >/dev/null && echo $HOSTNAME | sed 's/mysql-//' || echo 0))) \
		--auto-increment-offset=$((${SERVER_ID_BASE:-1} + $(echo $HOSTNAME | grep -e '^mysql-[0-9]$' >/dev/null && echo $HOSTNAME | sed 's/mysql-//' || echo 0))) \
		"$@"

fi
