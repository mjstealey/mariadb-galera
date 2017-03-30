#!/usr/bin/env bash
set -e

if [[ ${1} = 'galera' ]]; then
    /etc/init.d/mysql start

    # mysql_secure_installation
    tail -f /dev/null
else
    exec "$@"
fi




