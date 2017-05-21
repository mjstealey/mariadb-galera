# mariadb-galera
MariaDB 10.x Galera Cluster in CentOS 7 in Docker

This repository was built to serve as the foundation for an iRODS v.4.2.x provider back-ended by a clustered database iCAT instance as outlined in [mjstealey/irods-provider-galera](https://github.com/mjstealey/irods-provider-galera)

## Supported tags and respective Dockerfile links

- 10.1, latest ([10.1/Dockerfile](https://github.com/mjstealey/mariadb-galera/blob/master/10.1/Dockerfile))
- 10.2 ([10.2/Dockerfile](https://github.com/mjstealey/mariadb-galera/blob/master/10.2/Dockerfile))

### Pull image from dockerhub

```bash
docker pull mjstealey/mariadb-galera:latest
```

### Build locally

```
$ git clone https://github.com/mjstealey/mariadb-galera.git
$ cd mariadb-galera/10.1/
$ docker build -t mariadb-galera .
```

## Example

### three-node-test.sh

This script demonstrates how to stand up a three node Galera cluster in a local docker network named **galeranet**.

A database named `ICAT` is created and initialized by container **galera-node-1** based on the `init/initialize.sql` file. As containers **galera-node-2** and **galera-node-3** are created they will join the cluster as defined by `WSREP_CLUSTER_ADDRESS`.

The definition for each examaple node can be found in the `env/` directory.

When the script is run output similar to the following should be observed:

```
$ ./three-node-test.sh
### create docker network galeranet if it does not exist ###
### stop / remove existing containers ###
galera-node-1
galera-node-2
galera-node-3
galera-node-1
galera-node-2
galera-node-3
### show usage ###
Docker MariaDB Galera Cluster

docker-entrypoint [-hijv] [-f filename.sql] [arguments]

options:
-h                    show brief help
-i                    initialized galera cluster
-j                    join existing galera cluster
-v                    verbose output
-f filename.sql       provide SQL script to initialize database with from mounted volume
### start galera-node-1 and initialize cluster 'galera' with initialize.sql file ###
4e05c9abbe745a682d59fa318398985a1b503c7004a61a293f2a686afb34ba50
...
[MySQL]> SHOW STATUS LIKE 'wsrep_cluster_size';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 1     |
+--------------------+-------+
[MySQL]> SHOW databases;
+--------------------+
| Database           |
+--------------------+
| ICAT               |
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
[MySQL]> SHOW grants FOR 'irods'@'localhost';
+--------------------------------------------------------------------------------------------------------------+
| Grants for irods@localhost                                                                                   |
+--------------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'irods'@'localhost' IDENTIFIED BY PASSWORD '*60E38376E2C974797971A03D9BEEF1F5EB169FEA' |
| GRANT ALL PRIVILEGES ON `ICAT`.* TO 'irods'@'localhost'                                                      |
+--------------------------------------------------------------------------------------------------------------+
### start galera-node-2 and join cluster 'galera' ###
127e84d4c96f9048ca7bc420348b2c5d73bff7ff1475d2592a3545f6dbb6b375
...
[MySQL]> SHOW STATUS LIKE 'wsrep_cluster_size';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 2     |
+--------------------+-------+
[MySQL]> SHOW databases;
+--------------------+
| Database           |
+--------------------+
| ICAT               |
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
[MySQL]> SHOW grants FOR 'irods'@'localhost';
+--------------------------------------------------------------------------------------------------------------+
| Grants for irods@localhost                                                                                   |
+--------------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'irods'@'localhost' IDENTIFIED BY PASSWORD '*60E38376E2C974797971A03D9BEEF1F5EB169FEA' |
| GRANT ALL PRIVILEGES ON `ICAT`.* TO 'irods'@'localhost'                                                      |
+--------------------------------------------------------------------------------------------------------------+
### start galera-node-3 and join cluster 'galera' ###
69a47f82fc12942b83aa7cb7c3ee732e1f893150c36fc91f73e701d71e934978
...
[MySQL]> SHOW STATUS LIKE 'wsrep_cluster_size';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 3     |
+--------------------+-------+
[MySQL]> SHOW databases;
+--------------------+
| Database           |
+--------------------+
| ICAT               |
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
[MySQL]> SHOW STATUS LIKE 'wsrep_incoming_addresses';
+--------------------------+-------------------------------------------------+
| Variable_name            | Value                                           |
+--------------------------+-------------------------------------------------+
| wsrep_incoming_addresses | 172.18.0.2:3306,172.18.0.3:3306,172.18.0.4:3306 |
+--------------------------+-------------------------------------------------+
[MySQL]> SHOW grants FOR 'irods'@'localhost';
+--------------------------------------------------------------------------------------------------------------+
| Grants for irods@localhost                                                                                   |
+--------------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'irods'@'localhost' IDENTIFIED BY PASSWORD '*60E38376E2C974797971A03D9BEEF1F5EB169FEA' |
| GRANT ALL PRIVILEGES ON `ICAT`.* TO 'irods'@'localhost'                                                      |
+--------------------------------------------------------------------------------------------------------------+
```
