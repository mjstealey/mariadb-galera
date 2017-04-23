FROM centos:7
MAINTAINER Michael J. Stealey <michael.j.stealey@gmail.com>

# Explicitly set user/group IDs for mysql account
RUN groupadd -r mysql --gid=997 \
    && useradd -r -g mysql -d /var/lib/mysql --uid=997 mysql

ENV LANGUAGE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"

# install gosu
ENV GOSU_VERSION 1.10
RUN set -x \
    && yum -y install epel-release \
    && yum -y install wget dpkg \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /tmp/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /tmp/gosu.asc /usr/bin/gosu \
    && rm -r "$GNUPGHOME" /tmp/gosu.asc \
    && chmod +x /usr/bin/gosu \
    && gosu nobody true

# install prerequisites for MariaDB
RUN yum install -y \
    rsync \
    nmap \
    lsof \
    perl-DBI \
    nc \
    boost-program-options \
    iproute \
    iptables\
    libaio \
    libmnl \
    libnetfilter_conntrack \
    libnfnetlink \
    make \
    openssl \
    which

# install MariaDB 10.2.x
ADD ./MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum install -y \
    MariaDB-server \
    MariaDB-client \
    MariaDB-compat \
    galera \
    socat \
    jemalloc

# add docker-entrypoint script
ADD ./docker-entrypoint.sh /docker-entrypoint.sh

VOLUME ["var/lib/mysql"]

EXPOSE 3306 4567
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mysqld"]