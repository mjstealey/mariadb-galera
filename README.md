# mariadb-galera
MariaDB 10.x Galera Cluster on CentOS 7 in Docker

## Supported tags and respective Dockerfile links

- 10.1, latest ([10.1/Dockerfile](https://github.com/mjstealey/docker-irods-icat/blob/master/4.1.10/Dockerfile))
- 4.1.9 ([4.1.9/Dockerfile](https://github.com/mjstealey/docker-irods-icat/blob/master/4.1.9/Dockerfile))
- 4.1.8 ([4.1.8/Dockerfile](https://github.com/mjstealey/docker-irods-icat/blob/master/4.1.8/Dockerfile))
- 4.1.7 ([4.1.7/Dockerfile](https://github.com/mjstealey/docker-irods-icat/blob/master/4.1.7/Dockerfile))

4.2.x ([4.2.0-preview](https://github.com/mjstealey/irods-provider-postgres)) **This pre-release is for TESTING ONLY - do not use this on production deployments.**

### Docker image

[![](https://images.microbadger.com/badges/image/mjstealey/docker-irods-icat.svg)](https://microbadger.com/images/mjstealey/docker-irods-icat "Get your own image badge on microbadger.com")

### Pull image from dockerhub

```bash
docker pull mjstealey/docker-irods-icat:latest
```

### Usage:

Notes:

```
$ docker build -t mariadb .
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
	mariadb mysqld --init
$ docker run -d --name galera2 -h galera2 \
	-e MYSQL_ROOT_PASSWORD=password \
	--env-file=env/galera2.env \
	--net galeranet \
	--ip 172.18.0.3 \
	--add-host galera1:172.18.0.2 \
	--add-host galera3:172.18.0.4 \
	mariadb
$ docker run -d --name galera3 -h galera3 \
	-e MYSQL_ROOT_PASSWORD=password \
	--env-file=env/galera3.env \
	--net galeranet \
	--ip 172.18.0.4 \
	--add-host galera1:172.18.0.2 \
	--add-host galera2:172.18.0.3 \
	mariadb
```