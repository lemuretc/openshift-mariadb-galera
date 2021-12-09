#! /bin/bash

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script writes out a mysql galera config using a list of newline seperated
# peer DNS names it accepts through stdin.

# /etc/mysql is assumed to be a shared volume so we can modify my.cnf as required
# to keep the config up to date, without wrapping mysqld in a custom pid1.
# The config location is intentionally not /etc/mysql/my.cnf because the
# standard base image clobbers that location.
CFG=/etc/my.cnf.d/galera.cnf

function join {
    local IFS="$1"; shift; echo "$*";
}

#use IP address of the current pod
HOSTNAME=$(hostname -i)
# Parse out cluster name, from service name:
#CLUSTER_NAME="$(hostname -f | cut -d'.' -f2)"
#Cluster_name should be a variable defined in the Deployment Env.Vars
#WSREP_CLUSTER_ADDRESS - For sumariner case - cluster1.galera.etherpad.svc.clusterset.local,cluster2.galera.etherpad.svc.clusterset.local

waitLoop=1
peersChecked="Initial"

while [ $waitLoop -le 50 ]
do
   IFS=',' read -ra ADDR <<< "$WSREP_CLUSTER_ADDRESS"

   peersChecked="Yes"
   for i in "${ADDR[@]}"; do
     if resp=$(socat - tcp4:"$i":4455); then
       echo "yes $i = $resp"
       WSREP_CLUSTER_ADDRESS_IP+=($resp)
     else
       echo "Waiting for $i"
       peersChecked="No"
     fi
   done

   if [ $peersChecked == "Yes" ]; then
     waitLoop=999
     echo "Peers Ready"
   fi
   waitLoop=$(( $waitLoop + 1 ))
   echo "Waiting loop: $waitLoop ........ "
done

#make it visible globally
printf -v joined '%s,' "${WSREP_CLUSTER_ADDRESS_IP[@]}"
#echo "${joined%,}"
export WSREP_CLUSTER_ADDRESS_IP=$(echo "${joined%,}")
echo $WSREP_CLUSTER_ADDRESS_IP

sed -i -e "s|^wsrep_node_address=.*$|wsrep_node_address=${HOSTNAME}|" ${CFG}
sed -i -e "s|^wsrep_cluster_name=.*$|wsrep_cluster_name=${CLUSTER_NAME}|" ${CFG}
sed -i -e "s|^wsrep_cluster_address=.*$|wsrep_cluster_address=gcomm://${WSREP_CLUSTER_ADDRESS_IP}|" ${CFG}

# don't need a restart, we're just writing the conf in case there's an
# unexpected restart on the node.
