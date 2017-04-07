# mariadb-galera
MariaDB 10.1 Galera Cluster on CentOS 7 in Docker

Notes:

```
$ docker build -t mariadb .
$ docker network create --subnet=172.18.0.0/16 galeranet
```

Running the galera containers

```
$ docker run -d --name galera1 -h galera1 \
	-v /home/docker/mariadb-galera/init:/init \
	-e MYSQL_PASSWORD=password \
	--env-file=env/galera1.env \
	--net galeranet \
	--ip 172.18.0.2 \
	--add-host galera2:172.18.0.3 \
	--add-host galera3:172.18.0.4 \
	mariadb mysqld --init
$ docker run -d --name galera2 -h galera2 \
	-e MYSQL_PASSWORD=password \
	--env-file=env/galera2.env \
	--net galeranet \
	--ip 172.18.0.3 \
	--add-host galera1:172.18.0.2 \
	--add-host galera3:172.18.0.4 \
	mariadb
$ docker run -d --name galera3 -h galera3 \
	-e MYSQL_PASSWORD=password \
	--env-file=env/galera3.env \
	--net galeranet \
	--ip 172.18.0.4 \
	--add-host galera1:172.18.0.2 \
	--add-host galera2:172.18.0.3 \
	mariadb
```