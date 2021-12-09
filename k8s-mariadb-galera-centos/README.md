# Technical details

## build
- When building the image, the script `/usr/libexec/container-setup.sh` gets
  called
- This script creates data / config directories and sets their permissions
  accordingly

## run
- When running the image, the script `/usr/bin/container-entrypoint.sh` acts as
  a container entrypoint
- The entrypoint first checks if it's in an OpenShift / Kubernetes environment
  by inspecting the ENV variable `POD_NAMESPACE`
  - If `POD_NAMESPACE` is set, the entrypoint runs the command 
    `/usr/bin/peer-finder` which looks for other nodes. `peer-finder` then
    calls the script `/usr/share/container-scripts/mysql/configure-galera.sh`
    which creates a galera-config at `/etc/my.cnf.d/galera.cnf`
- Next, the entrypoint checks if the directory `/var/lib/mysql/mysql` exists. 
  If not, it assumes that mysql needs to be set up, thus it calls the script
  `/usr/share/container-scripts/mysql/configure-mysql.sh`
  - This script creates a fist time mysql config which sets up users, tables,
    etc. 
- After that, the entrypoint calls `mysqld` with correct flags to run mysqld


## readinessProbe
- The readinessProbe lives in
  `/usr/share/container-scripts/mysql/readiness-probe.sh`, if the script exits
  with 0, the container is ready, other error codes are interpreted as
  `notReady`


## peer-finder
for Galera Cluster to start we used a simple logic. When container start it exposes POD IP address. Unfortinately Galera did not work properly with DNS names. So finding the POD IP address was an important step. Each POD broadcasts the IP and at the same time trying to find Peers. Using variable `WSREP_CLUSTER_ADDRESS` bash script trying to reachout to each service and resolve POD IP instead of Service IP. When it is done master is elected by the minimal IP address.
This logic is not great but it is sufficient for the DEMO. if POD is down it may not notify others. classical split brain issue, etc. in real life you need to handle all possible combinations.
