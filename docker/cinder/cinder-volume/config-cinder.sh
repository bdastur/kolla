#!/bin/sh
set -ex

. /opt/kolla/kolla-common.sh

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

lvm=/etc/lvm/lvm.conf
cfg=/etc/cinder/cinder.conf
ceph=/etc/ceph/ceph.conf
keyring=/etc/ceph/client.cinder.keyring

if [[ ${VOLUME_DRIVER,,} == lvm ]];then

  export http_proxy=${HTTP_PROXY_ADDR}
  export https_proxy=${HTTPS_PROXY_ADDR}

  #Installing tgt-admin
  yum -y install scsi-target-utils

  unset http_proxy
  unset https_proxy

  #Adding cinder volumes to tgtd config
  echo "include /etc/cinder/volumes/*" >> /etc/tgt/tgtd.conf

  #Starting tgtd
  /usr/sbin/tgtd

  #Starting iscsid
  #/usr/sbin/iscsid

  #disable lvmetad and udev in lvm configuration
  sed -i 's/use_lvmetad = 1/use_lvmetad = 0/g' $lvm
  sed -i 's/udev_sync = 1/udev_sync = 0/g' $lvm
  sed -i 's/udev_rules = 1/udev_rules = 0/g' $lvm

  #Adding LVM filter
  sed -i 's:filter = \[ "a/.\*/" \]:filter = \[ "a/sda/", "r/.\*/"\]:g' $lvm

  # lvm
  crudini --set $cfg \
      DEFAULT \
      volume_group \
      "${VOLUME_GROUP}"

  # iscsi
  crudini --set $cfg \
      DEFAULT \
      iscsi_helper \
      "tgtadm"
elif [[ ${VOLUME_DRIVER,,} == ceph ]];then
  # Installing ceph client
  yum -y install ceph

  # Copying config files
  cp ${CINDER_CONFIG_SCRIPT_PATH}/ceph.conf /etc/ceph/
  cp ${CINDER_CONFIG_SCRIPT_PATH}/client.cinder.keyring /etc/ceph/

  # ceph
  crudini --set $cfg \
      DEFAULT \
      volume_driver \
      "cinder.volume.drivers.rbd.RBDDriver"

  crudini --set $cfg \
      DEFAULT \
      rbd_pool \
      "${RBD_POOL}"  

  crudini --set $cfg \
      DEFAULT \
      rbd_ceph_conf \
      "/etc/ceph/ceph.conf"

  crudini --set $cfg \
      DEFAULT \
      rbd_flatten_volume_from_snapshot \
      "false"

  crudini --set $cfg \
      DEFAULT \
      rbd_max_clone_depth \
      "5"

  crudini --set $cfg \
      DEFAULT \
      rbd_store_chunk_size \
      "4"

  crudini --set $cfg \
      DEFAULT \
      rados_connect_timeout \
      "-1"

  crudini --set $cfg \
      DEFAULT \
      glance_api_version \
      "2"

  crudini --set $cfg \
      DEFAULT \
      rbd_user \
      "cinder"

  crudini --set $cfg \
      DEFAULT \
      rbd_secret_uuid \
      "${SECRET_UUID}"

  crudini --set $ceph \
      global \
      fsid \
      "${CLUSTER_ID}"

  crudini --set $ceph \
      global \
      mon_host \
      "${MON_HOSTS}"

  crudini --set $ceph \
      global \
      mon_initial_members \
      "${MON_MEMBERS}"

  crudini --set $keyring \
      client.cinder \
      key \
      "${CLIENT_KEY}"
fi


crudini --set $cfg \
    DEFAULT \
    my_ip \
    "${CINDER_HOST}"

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

