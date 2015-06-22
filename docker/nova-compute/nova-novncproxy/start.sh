#!/bin/sh

set -e

. /opt/kolla/config-nova.conf

echo "Starting nova-novncproxy."
exec /usr/bin/nova-novncproxy
