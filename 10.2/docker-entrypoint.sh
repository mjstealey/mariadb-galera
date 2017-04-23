#!/usr/bin/env bash
set -e

_server_cnf() {
    echo "set /etc/my.cnf.d/server.cnf"
    > /etc/my.cnf.d/server.cnf
    echo "[galera]" >> /etc/my.cnf.d/server.cnf
    echo "# Mandatory settings" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_on=${WSREP_ON}" >> /etc/my.cnf.d/server.cnf
    echo "wsrep_provider=${WSREP_PROVIDER}" >> /etc/my.cnf.d/server.cnf
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

if [[ ${1} = 'mysqld' ]]; then
    gosu root /etc/init.d/mysql start
    _mysql_secure_installation
    if [[ ${2} = '--init' ]]; then
        # mysql --user=user_name --password=your_password db_name
        gosu root mysql --user=root --password=${MYSQL_ROOT_PASSWORD} < /init/initialize.sql
        gosu root mysqldump --user=root --password=${MYSQL_ROOT_PASSWORD} --all-databases > /init/db.sql
    fi
    gosu root /etc/init.d/mysql stop
    _server_cnf
    cat /etc/my.cnf.d/server.cnf
    gosu root /etc/init.d/mysql start
    gosu root ss -lntu
    gosu root tail -f /dev/null
else
    exec "$@"
fi




