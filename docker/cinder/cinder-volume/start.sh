#!/bin/sh
set -ex

cp ${CINDER_CONFIG_SCRIPT_PATH}/config-cinder.sh /opt/kolla/.
. /opt/kolla/kolla-common.sh
. /opt/kolla/config-cinder.sh


check_required_vars KEYSTONE_ADMIN_TOKEN KEYSTONE_ADMIN_SERVICE_HOST \
                    PUBLIC_IP CINDER_API_SERVICE_HOST

check_for_db
check_for_keystone


echo "Starting cinder-volume"
exec /usr/bin/cinder-volume

