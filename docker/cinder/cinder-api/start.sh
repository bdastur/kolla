#!/bin/sh

set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-cinder.sh

: ${CINDER_DB_USER:=cinder}
: ${CINDER_DB_NAME:=cinder}
: ${KEYSTONE_AUTH_PROTOCOL:=http}
: ${CINDER_KEYSTONE_USER:=cinder}
: ${ADMIN_TENANT_NAME:=admin}
: ${KEYSTONE_ADMIN_SERVICE_HOST:=172.31.231.120}
: ${KEYSTONE_ADMIN_TOKEN:=changeme}
: ${CINDER_API_SERVICE_HOST:=172.31.231.120}


if ! [ "$CINDER_DB_PASSWORD" ]; then
        CINDER_DB_PASSWORD=$(openssl rand -hex 15)
        export CINDER_DB_PASSWORD
fi

check_required_vars KEYSTONE_ADMIN_TOKEN KEYSTONE_ADMIN_SERVICE_HOST \
                    PUBLIC_IP CINDER_API_SERVICE_HOST

check_for_db
check_for_keystone

mysql -h ${MARIADB_SERVICE_HOST} -u root -p"${DB_ROOT_PASSWORD}" mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${CINDER_DB_NAME};
GRANT ALL PRIVILEGES ON ${CINDER_DB_NAME}.* TO
        '${CINDER_DB_USER}'@'%' IDENTIFIED BY '${CINDER_DB_PASSWORD}'
EOF
#GRANT ALL PRIVILEGES ON glance* TO
#        '${CINDER_DB_USER}'@'%' IDENTIFIED BY '${CINDER_DB_PASSWORD}'


#wait_for 30 1 check_for_os_service_running keystone
#wait_for 25 1 check_for_db $CINDER_DB_NAME

export SERVICE_TOKEN="${KEYSTONE_ADMIN_TOKEN}"
export SERVICE_ENDPOINT="${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_ADMIN_SERVICE_HOST}:35357/v2.0"

crux user-create --update \
    -n "${CINDER_KEYSTONE_USER}" \
    -p "${CINDER_KEYSTONE_PASSWORD}" \
    -t "${ADMIN_TENANT_NAME}" \
    -r admin

crux endpoint-create --remove-all \
    -n cinder -t volume \
    -P "http://${KEYSTONE_PUBLIC_SERVICE_HOST}:8776/v1/\$(tenant_id)s" \
    -A "http://${KEYSTONE_PUBLIC_SERVICE_HOST}:8776/v1/\$(tenant_id)s" \
    -I "http://${CINDER_API_SERVICE_HOST}:8776/v1/\$(tenant_id)s"

#-----Cinder.conf setup-----

# Cinder database
crudini --set /etc/cinder/cinder.conf \
        DEFAULT \
        db_driver \
        "cinder.db"

# control_exchange
crudini --set /etc/cinder/cinder.conf \
        DEFAULT \
        control_exchange \
        "openstack"

# osapi
crudini --set /etc/cinder/cinder.conf \
        DEFAULT \
    osapi_volume_listen \
        "${CINDER_HOST}"

# iscsi
crudini --set /etc/cinder/cinder.conf \
        DEFAULT \
        iscsi_ip_address \
        "127.0.0.1"
crudini --set /etc/cinder/cinder.conf \
        DEFAULT \
    iscsi_helper \
        "tgtadm"

# volume_group
crudini --set /etc/cinder/cinder.conf \
        DEFAULT \
        volume_group \
    "cinder-volumes"


/usr/bin/cinder-manage db sync


echo "Starting cinder-api"
exec /usr/bin/cinder-api

