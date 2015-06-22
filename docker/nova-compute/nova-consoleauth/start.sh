#!/bin/sh

set -e

. /opt/kolla/config-nova.conf

echo "Starting nova-consoleauth."
exec /usr/bin/nova-consoleauth
