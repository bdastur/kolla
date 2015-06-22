#!/bin/bash

set -e

cp /dockers/cinder_scheduler/config-cinder.sh /opt/kolla/.
. /opt/kolla/kolla-common.sh
. /opt/kolla/config-cinder.sh

echo "Starting cinder-scheduler"
exec /usr/bin/cinder-scheduler

