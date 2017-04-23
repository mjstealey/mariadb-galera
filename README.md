# mariadb-galera
MariaDB 10.x Galera Cluster in CentOS 7 in Docker

This repository was built to serve as the foundation for an iRODS v.4.2.0 provider back-ended by a clustered database iCAT instance as outlined in [mjstealey/irods-provider-galera](https://github.com/mjstealey/irods-provider-galera)

## Supported tags and respective Dockerfile links

- 10.1, latest ([10.1/Dockerfile](https://github.com/mjstealey/mariadb-galera/blob/master/10.1/Dockerfile))
- 10.2 ([10.2/Dockerfile](https://github.com/mjstealey/mariadb-galera/blob/master/10.2/Dockerfile))

### Pull image from dockerhub

```bash
docker pull mjstealey/mariadb-galera:latest
```

### Build locally

```
$ cd 10.1/
$ docker build -t mariadb-galera .
```

### Usage:

Create local network

```
$ docker network create --subnet=172.18.0.0/16 galeranet
```

Running the galera containers

```
$ docker run -d --name galera1 -h galera1 \
	-v /home/docker/mariadb-galera/init:/init \
	-e MYSQL_ROOT_PASSWORD=password \
	--env-file=env/galera1.env \
	--net galeranet \
	--ip 172.18.0.2 \
	--add-host galera2:172.18.0.3 \
	--add-host galera3:172.18.0.4 \
	mjstealey/mariadb-galera:latest mysqld --init
$ docker run -d --name galera2 -h galera2 \
	-e MYSQL_ROOT_PASSWORD=password \
	--env-file=env/galera2.env \
	--net galeranet \
	--ip 172.18.0.3 \
	--add-host galera1:172.18.0.2 \
	--add-host galera3:172.18.0.4 \
	mjstealey/mariadb-galera:latest
$ docker run -d --name galera3 -h galera3 \
	-e MYSQL_ROOT_PASSWORD=password \
	--env-file=env/galera3.env \
	--net galeranet \
	--ip 172.18.0.4 \
	--add-host galera1:172.18.0.2 \
	--add-host galera2:172.18.0.3 \
	mjstealey/mariadb-galera:latest
```

Simple test: A database named `ICAT` created and initialized by container **galera1** based on the `init/initialize.sql` file. As containers **galera2** and **galera3** were created they were configured to join the cluster as defined by `WSREP_CLUSTER_ADDRESS`.

The `ICAT` database should be viable from all three galera containers.

```
$ docker exec galera1 mysql --user=root --password=password -e "show databases;"
Database
ICAT
information_schema
mysql
performance_schema
$ docker exec galera2 mysql --user=root --password=password -e "show databases;"
Database
ICAT
information_schema
mysql
performance_schema
$ docker exec galera3 mysql --user=root --password=password -e "show databases;"
Database
ICAT
information_schema
mysql
performance_schema
```