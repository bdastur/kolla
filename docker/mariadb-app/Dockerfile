FROM %%KOLLA_NAMESPACE%%/%%KOLLA_PREFIX%%base
MAINTAINER Kolla Project (https://launchpad.net/kolla)


# Add Percona.repo
ADD /Percona.repo /etc/yum.repos.d/Percona.repo

RUN yum install -y socat  \
    mariadb-galera-server galera  \
    percona-xtrabackup nc \
    hostname \
    && yum clean all


# Add mysql configuration scripts
ADD config-mysql.sh /opt/kolla/config-mysql.sh
ADD mysql-entrypoint.sh /opt/kolla/mysql-entrypoint.sh

# start mysql
ENTRYPOINT ["/opt/kolla/mysql-entrypoint.sh"]
CMD ["mysqld_safe"]
