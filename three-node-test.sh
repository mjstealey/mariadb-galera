#!/usr/bin/env bash

REPO_DIR=$(pwd)

# create docker network if it does not exist
GALERANET=$(docker network inspect galeranet)
echo "### create docker network galeranet if it does not exist ###"
if [[ "${GALERANET}" = '[]' ]]; then
    docker network create --subnet=172.18.0.0/16 galeranet
fi

# stop / remove existing containers
echo "### stop / remove existing containers ###"
if [[ -n $(docker ps -a | grep galera-node) ]]; then
    docker stop galera-node-1 galera-node-2 galera-node-3
    docker rm -fv galera-node-1 galera-node-2 galera-node-3
fi

# show usage
echo "### show usage ###"
docker run --rm mjstealey/mariadb-galera:10.1 -h mysqld

# init galera-node-1
echo "### start galera-node-1 and initialize cluster 'galera' with initialize.sql file ###"
docker run -d --name galera-node-1 -h galera-node-1 \
    -v ${REPO_DIR}/init:/init \
    --env-file=env/galera-node-1.env \
    --net galeranet \
    --ip 172.18.0.2 \
    --add-host galera-node-2:172.18.0.3 \
    --add-host galera-node-3:172.18.0.4 \
    -p 3306 -p 4444 -p 4567 -p 4568 \
    mjstealey/mariadb-galera:10.1 -vif initialize.sql mysqld

for pc in $(seq 15 -1 1); do
    echo -ne "$pc ...\033[0K\r" && sleep 1;
done
echo "[MySQL]> SHOW STATUS LIKE 'wsrep_cluster_size';"
docker exec -ti galera-node-1 mysql -uroot -ptemppassword -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
echo "[MySQL]> SHOW databases;"
docker exec -ti galera-node-1 mysql -uroot -ptemppassword -e "SHOW databases;"
echo "[MySQL]> SHOW grants FOR 'irods'@'localhost';"
docker exec -ti galera-node-1 mysql -uroot -ptemppassword ICAT -e \
"SHOW grants FOR 'irods'@'localhost';"

# init galera-node-2
echo "### start galera-node-2 and join cluster 'galera' ###"
docker run -d --name galera-node-2 -h galera-node-2 \
    --env-file=env/galera-node-2.env \
    --net galeranet \
    --ip 172.18.0.3 \
    --add-host galera-node-1:172.18.0.2 \
    --add-host galera-node-3:172.18.0.4 \
    -p 3306 -p 4444 -p 4567 -p 4568 \
    mjstealey/mariadb-galera:10.1 -vj mysqld

for pc in $(seq 15 -1 1); do
    echo -ne "$pc ...\033[0K\r" && sleep 1;
done
echo "[MySQL]> SHOW STATUS LIKE 'wsrep_cluster_size';"
docker exec -ti galera-node-2 mysql -uroot -ptemppassword -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
echo "[MySQL]> SHOW databases;"
docker exec -ti galera-node-2 mysql -uroot -ptemppassword -e "SHOW databases;"
echo "[MySQL]> SHOW grants FOR 'irods'@'localhost';"
docker exec -ti galera-node-2 mysql -uroot -ptemppassword ICAT -e \
"SHOW grants FOR 'irods'@'localhost';"

# init galera-node-3
echo "### start galera-node-3 and join cluster 'galera' ###"
docker run -d --name galera-node-3 -h galera-node-3 \
    --env-file=env/galera-node-3.env \
    --net galeranet \
    --ip 172.18.0.4 \
    --add-host galera-node-1:172.18.0.2 \
    --add-host galera-node-2:172.18.0.3 \
    -p 3306 -p 4444 -p 4567 -p 4568 \
    mjstealey/mariadb-galera:10.1 -vj mysqld

for pc in $(seq 15 -1 1); do
    echo -ne "$pc ...\033[0K\r" && sleep 1;
done
echo "[MySQL]> SHOW STATUS LIKE 'wsrep_cluster_size';"
docker exec -ti galera-node-3 mysql -uroot -ptemppassword -e \
"SHOW STATUS LIKE 'wsrep_cluster_size';"
echo "[MySQL]> SHOW databases;"
docker exec -ti galera-node-3 mysql -uroot -ptemppassword -e "SHOW databases;"
echo "[MySQL]> SHOW STATUS LIKE 'wsrep_incoming_addresses';"
docker exec -ti galera-node-3 mysql -uroot -ptemppassword -e \
"SHOW STATUS LIKE 'wsrep_incoming_addresses';"
echo "[MySQL]> SHOW grants FOR 'irods'@'localhost';"
docker exec -ti galera-node-3 mysql -uroot -ptemppassword ICAT -e \
"SHOW grants FOR 'irods'@'localhost';"

exit 0;