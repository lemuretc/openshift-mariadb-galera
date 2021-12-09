# MariaDB Galera cluster on OpenShift 
## Replication via Submariner


[![License](https://img.shields.io/github/license/adfinis-sygroup/openshift-mariadb-galera.svg?style=flat-square)](LICENSE)


## Requirements
- OpenShift 4.x 


## General informations

### Environment variables and volumes

The image recognizes the following environment variables that you can set during
initialization by passing

|  Variable name          | Description                               |
| :---------------------- | ----------------------------------------- |
|  `MYSQL_USER`           | User name for MySQL account to be created |
|  `MYSQL_PASSWORD`       | Password for the user account             |
|  `MYSQL_DATABASE`       | Database name                             |
|  `MYSQL_ROOT_PASSWORD`  | Password for the root user (optional)     |
|  `WSREP_CLUSTER_ADDRESS`| Cluster service names                     |

As per Submariner the service name is resolved as 

`<cluster>.<service>.<namespace>.svc.clusterset.local`
In the example I use 
`WSREP_CLUSTER_ADDRESS=cluster1.galera.etherpad.svc.clusterset.local,cluster2.galera.etherpad.svc.clusterset.local`

You can also set the following mount points by passing the `-v /host:/container`
flag to Docker.

| Volume mount point       | Description          |
| :----------------------- | -------------------- |
|  `/var/lib/mysql`        | MySQL data directory |

**Notice: When mouting a directory from the host into the container,
ensure that the mounted directory has the appropriate permissions and
that the owner and group of the directory matches the user UID or name
which is running inside the container.**


## Usage in OpenShift


If choosing the persistent template, make sure that the PV's are created in the
namespace of your project and match the `VOLUME_PV_NAME` and `VOLUME_CAPACITY`
parameters of the template.


### cluster creation

Used this sample for demo purpose. Advanced Cluster Manager controlling the app including stateful sets. See details here

https://github.com/lemuretc/rhacm-labs

**Note: for Galera Cluster to start we used a simple logic. When container start it exposes POD IP address. Unfortinately Galera did not work properly with DNS names. So finding the POD IP address was an important step. Each POD broadcasts the IP and at the same time trying to find Peers. Using variable `WSREP_CLUSTER_ADDRESS` bash script trying to reachout to each service and resolve POD IP instead of Service IP. When it is done master is elected by the minimal IP address.
This logic is not great but it is sufficient for the DEMO. if POD is down it may not notify others. classical split brain issue, etc. in real life you need to handle all possible combinations.
**



## Contributions
Contributions are more than welcome! Please feel free to open new issues or
pull requests.


## License
GNU GENERAL PUBLIC LICENSE Version 3

See the [LICENSE](LICENSE) file.
