#!/bin/sh

set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-ceilometer.sh


exec /usr/bin/ceilometer-alarm-evaluator &
exec /usr/bin/ceilometer-alarm-notifier
