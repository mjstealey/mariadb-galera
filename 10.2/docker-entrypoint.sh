#!/usr/bin/env bash
set -e

package='docker-entrypoint'
init=false
join=false
usage=false
verbose=false
sqlfile=''
mysqld=false

_server_cnf() {
    echo "set /etc/my.cnf.d/server.cnf"
    > /etc/my.cnf.d/server.cnf
    echo "[galera]" >> /etc/my.cnf.d/server.cnf
    echo "# Mandatory settings" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_on=${WSREP_ON}" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_provider=${WSREP_PROVIDER}" >> /etc/my.cnf.d/server.cnf
    if [[ ! -z "${WSREP_PROVIDER_OPTIONS// }" ]]; then
        echo "wsrep_provider_options"=${WSREP_PROVIDER_OPTIONS} >> /etc/my.cnf.d/server.cnf
    fi
    echo "wsrep_cluster_address=${WSREP_CLUSTER_ADDRESS}" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_cluster_name=${WSREP_CLUSTER_NAME}" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_node_address=${WSREP_NODE_ADDRESS}" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_node_name=${WSREP_NODE_NAME}" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_sst_method=${WSREP_SST_METHOD}" >> /etc/my.cnf.d/server.cnf
    echo "" >> /etc/my.cnf.d/server.cnf
    echo "binlog_format=${BINLOG_FORMAT}" >> /etc/my.cnf.d/server.cnf
    echo "default_storage_engine=${DEFAULT_STORAGE_ENGINE}" >> /etc/my.cnf.d/server.cnf
    echo "innodb_autoinc_lock_mode=${INNODB_AUTOINC_LOCK_MODE}" >> /etc/my.cnf.d/server.cnf
    echo "bind-address=${BIND_ADDRESS}" >> /etc/my.cnf.d/server.cnf
}

_mysql_secure_installation() {
    echo "exec mysql_secure_installation"
    > /.msi_response
    echo "" >> /.msi_response
    echo "y" >> /.msi_response
    echo "${MYSQL_ROOT_PASSWORD}" >> /.msi_response
    echo "${MYSQL_ROOT_PASSWORD}" >> /.msi_response
    echo "y" >> /.msi_response
    echo "y" >> /.msi_response
    echo "y" >> /.msi_response
    echo "y" >> /.msi_response
    mysql_secure_installation < /.msi_response
}

_usage() {
    echo "Docker MariaDB Galera Cluster"
    echo " "
    echo "$package [-hijv] [-f filename.sql] [arguments]"
    echo " "
    echo "options:"
    echo "-h                    show brief help"
    echo "-i                    initialized galera cluster"
    echo "-j                    join existing galera cluster"
    echo "-v                    verbose output"
    echo "-f filename.sql       provide SQL script to initialize database with from mounted volume"
    exit 0
}

while getopts 'hijvf:q' opt; do
  case "${opt}" in
    h) usage=true ;;
    i) init=true ;;
    j) join=true ;;
    f) sqlfile="${OPTARG}" ;;
    v) verbose=true ;;
    ?) echo "Invalid option provided" && usage=true ;;
  esac
done

for var in "$@"
do
    if [[ "${var}" = 'mysqld' ]]; then
        mysqld=true
    fi
done

if $mysqld; then
    if $usage; then
        _usage
    fi
    gosu root /etc/init.d/mysql start
    _mysql_secure_installation
    if [[ -e /init/${sqlfile} ]]; then
        gosu root mysql -uroot -p${MYSQL_ROOT_PASSWORD} < /init/${sqlfile}
        gosu root mysqldump -uroot -p${MYSQL_ROOT_PASSWORD} --all-databases > /init/db.sql
    fi
    gosu root /etc/init.d/mysql stop
    _server_cnf
    if $verbose; then
        echo "$ cat /etc/my.cnf.d/server.cnf"
        cat /etc/my.cnf.d/server.cnf
    fi
    if $init; then
        gosu root /etc/init.d/mysql start --wsrep-new-cluster
    fi
    if $join; then
        gosu root /etc/init.d/mysql start
    fi
    if $verbose; then
        echo "[MySQL]> SHOW VARIABLES LIKE 'wsrep%';"
        gosu root mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW VARIABLES LIKE 'wsrep%';" \
        | fold -w 80 -s
        echo "$ ss -lntu"
        gosu root ss -lntu
    fi
    gosu root tail -f /dev/null
else
    exec "$@"
fi




