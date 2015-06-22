#!/bin/sh

set -e

. /opt/kolla/kolla-common.sh

: ${ADMIN_TENANT_NAME:=admin}
: ${CINDER_DB_NAME:=cinder}
: ${CINDER_DB_USER:=cinder}
: ${CINDER_DB_PASSWORD:=password}
: ${CINDER_KEYSTONE_USER:=cinder}
: ${CINDER_KEYSTONE_PASSWORD:=password}
: ${MARIADB_SERVICE_HOST:=172.31.231.120}
: ${GLANCE_API_SERVICE_HOST:=172.31.231.120}
: ${KEYSTONE_PUBLIC_SERVICE_HOST:=172.31.231.120}
: ${KEYSTONE_AUTH_PROTOCOL:=http}
: ${DB_ROOT_PASSWORD:=password}
#: ${PUBLIC_IP:=$CINDER_API_PORT_8004_TCP_ADDR}
#: ${PUBLIC_IP:=172.31.231.120}
: ${RABBITMQ_PORT:=5672}
: ${RABBITMQ_HOSTS:=localhost:$RABBITMQ_PORT}
: ${RABBITMQ_USER:=guest}
: ${RABBITMQ_PASSWORD:=guest}

check_required_vars CINDER_DB_PASSWORD CINDER_KEYSTONE_PASSWORD \
                    KEYSTONE_PUBLIC_SERVICE_HOST \
                    GLANCE_API_SERVICE_HOST MARIADB_SERVICE_HOST

dump_vars

cat > /openrc <<EOF
export OS_AUTH_URL=http://${KEYSTONE_PUBLIC_SERVICE_HOST}:${KEYSTONE_PUBLIC_SERVICE_PORT}/v2.0
export OS_USERNAME=${ADMIN_USER}
export OS_PASSWORD=${ADMIN_USER_PASSWORD}
export OS_TENANT_NAME=${ADMIN_TENANT_NAME}
EOF

cfg=/etc/cinder/cinder.conf

# logs
crudini --set $cfg \
        DEFAULT \
        log_dir \
    "/var/log/cinder/"

crudini --set $cfg \
        DEFAULT \
        log_file \
    "/var/log/cinder/cinder.log"

# verbose
crudini --set $cfg \
        DEFAULT \
    verbose \
    "${VERBOSE_LOGGING}"

# debug
crudini --set $cfg \
        DEFAULT \
        debug \
    "${DEBUG_LOGGING}"

# backend
crudini --set $cfg \
        DEFAULT \
        rpc_backend \
        "cinder.openstack.common.rpc.impl_kombu"

# rabbit
#crudini --set $cfg \
#        DEFAULT \
#        rabbit_host \
#        ${RABBITMQ_SERVICE_HOST}
#crudini --set $cfg \
#        DEFAULT \
#        rabbit_port \
#        "${RABBITMQ_PORT}"
crudini --set $cfg \
        DEFAULT \
        rabbit_hosts \
        "${RABBITMQ_HOSTS}"
crudini --set $cfg \
        DEFAULT \
        rabbit_userid \
        ${RABBITMQ_USER}
crudini --set $cfg \
        DEFAULT \
        rabbit_password \
        "${RABBITMQ_PASSWORD}"
crudini --set $cfg \
        DEFAULT \
        rabbit_virtual_host \
        "/"
crudini --set $cfg \
        DEFAULT \
        rabbit_ha_queues \
        "False"

# glance
crudini --set $cfg \
        DEFAULT \
        glance_host \
        ${GLANCE_API_SERVICE_HOST}

# database
crudini --set $cfg \
        database \
        connection \
        mysql://${CINDER_DB_USER}:${CINDER_DB_PASSWORD}@${MARIADB_SERVICE_HOST}/${CINDER_DB_NAME}

# keystone
crudini --set $cfg \
        DEFAULT \
        auth_strategy \
        "keystone"
#crudini --set $cfg \
#        keystone_authtoken \
#        auth_protocol \
#        ${KEYSTONE_AUTH_PROTOCOL}
#crudini --set $cfg \
#        keystone_authtoken \
#        auth_host \
#        ${KEYSTONE_ADMIN_SERVICE_HOST}
#crudini --set $cfg \
#        keystone_authtoken \
#        auth_port \
#        ${KEYSTONE_ADMIN_SERVICE_PORT}
crudini --set $cfg \
        keystone_authtoken \
        identity_uri \
        "${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_PUBLIC_SERVICE_HOST}:${KEYSTONE_ADMIN_SERVICE_PORT}/"
crudini --set $cfg \
        keystone_authtoken \
        auth_uri \
        "${KEYSTONE_AUTH_PROTOCOL}://${KEYSTONE_PUBLIC_SERVICE_HOST}:${KEYSTONE_PUBLIC_SERVICE_PORT}/v2.0"
crudini --set $cfg \
        keystone_authtoken \
        admin_tenant_name \
        ${ADMIN_TENANT_NAME}
crudini --set $cfg \
        keystone_authtoken \
        admin_user \
        ${CINDER_KEYSTONE_USER}
crudini --set $cfg \
        keystone_authtoken \
        admin_password \
        "${CINDER_KEYSTONE_PASSWORD}"
