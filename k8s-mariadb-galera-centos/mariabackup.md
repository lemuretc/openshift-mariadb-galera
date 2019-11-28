# streaming backup with mariabackup from one Galera node to slave in KA
https://mariadb.com/kb/en/library/full-backup-and-restore-with-mariabackup/
https://mariadb.com/kb/en/library/manual-sst-of-galera-cluster-node-with-mariabackup/
https://mariadb.com/kb/en/library/using-encryption-and-compression-tools-with-mariabackup/

- backup-mail# docker-compose stop
- ka-kube0# kubectl delete pod mysql-0
- ka-kube1# cd /var/lib/mysql; rm -rf *
- ka-kube1# docker run --net host -it --rm --entrypoint bash -v /data/datadir-mysql-0:/var/lib/mysql quay.io/egroupware/galera:10.3.13-gtid
bash$ cd /var/lib/mysql
bash$ socat TCP-LISTEN:9999 - | gzip -d | mbstream -x
bash$ chown -R 27:0 /var/lib/mysql
- dev# screen kubectl exec -it mysql-0 bash
bash$ mariabackup --backup --slave-info --galera-info --no-timestamp --user xtrabackup_sst --password xtrabackup_sst --stream=xbstream | gzip | socat - TCP:10.44.99.181:9999
MySQL binlog position: filename 'binlog.002583', position '459', GTID of the last change '0-1-4515,1-1-2479054537,10-1-7507905'

root@ka-kube1:/data/datadir-mysql-0# cat xtrabackup_info
uuid = 1841cc41-87d5-11e9-8fd6-c2cc477158e8
name =
tool_name = mariabackup
tool_command = --backup --slave-info --galera-info --no-timestamp --user xtrabackup_sst --password=... xtrabackup_sst --stream=xbstream
tool_version = 10.3.13-MariaDB
ibbackup_version = 10.3.13-MariaDB
server_version = 10.3.13-MariaDB-log
start_time = 2019-06-05 22:15:57
end_time = 2019-06-05 23:01:31
lock_time = 0
binlog_pos = filename 'binlog.002583', position '459', GTID of the last change '0-1-4515,1-1-2479054537,10-1-7507905'
innodb_from_lsn = 0
innodb_to_lsn = 3606046546254
partial = N
incremental = N
format = tar
compressed = N

root@ka-kube1:/data/datadir-mysql-0# cat xtrabackup_galera_info
7c2f0fd8-ebe7-11e8-b215-17aca4d36ccc:85749425

root@ka-kube1:/data/datadir-mysql-0# cat grastate.dat
# GALERA saved state
version: 2.1
uuid:    7c2f0fd8-ebe7-11e8-b215-17aca4d36ccc
seqno:   85749425
safe_to_bootstrap: 1

root@ka-kube0:~/kubernetes-farm/galera# kubectl create -f mysql-0.yml
pod/mysql-0 created
root@ka-kube0:~/kubernetes-farm/galera# kubectl logs -f mysql-0

# backup a node to NFS backup volumn with mariadb DOES NOT WORK!

dev@dev:/opt/backup$ sudo mkdir mysql-0-201905212030
dev@dev:/opt/backup$ sudo chown 27 mysql-0-201905212030
dev@dev:/opt/backup$ kubectl exec -it mysql-0 bash
bash-4.2$ mariabackup --backup --slave-info --galera-info --no-timestamp \
	--target-dir /var/backup/mysql-0-201905212030 \
	--user xtrabackup_sst --password ******

mariabackup: Error writing file '/var/backup/mysql-0-201905212030/egw_pec/egw_history_log.ibd' (Errcode: 5 "Input/output error")
[01] 2019-05-21 20:56:52 mariabackup: xtrabackup_copy_datafile() failed.
[00] FATAL ERROR: 2019-05-21 20:56:52 failed to copy datafile.

