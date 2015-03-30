#!/bin/sh

set -ex

: ${RABBITMQ_USER:=guest}
: ${RABBITMQ_PASS:=guest}
: ${RABBITMQ_NODENAME:=rabbit}
: ${RABBITMQ_LOG_BASE:=/var/log/rabbitmq}
: ${RABBITMQ_SERVICE_HOST:=127.0.0.1}

# RabbitMQ HA Configuration Parameters.
: ${RABBITMQ_ERLANG_COOKIE:=YUIGIJQZYEWJXSLNZGHW}
: ${RABBITMQ_PORT:=5672}

iptables -A INPUT -p tcp --dport 15672 -j ACCEPT
iptables -A INPUT -p tcp --dport 5672 -j ACCEPT
iptables -A INPUT -p tcp --dport 35197 -j ACCEPT
iptables -A INPUT -p tcp --dport 4369 -j ACCEPT
iptables-save

sed -i '
        s|@RABBITMQ_USER@|'"$RABBITMQ_USER"'|g
        s|@RABBITMQ_PASS@|'"$RABBITMQ_PASS"'|g
    s|@RABBITMQ_NODES@|'"$RABBITMQ_NODES"'|g
' /etc/rabbitmq/rabbitmq.config

sed -i '
        s|@RABBITMQ_LOG_BASE@|'"$RABBITMQ_LOG_BASE"'|g
    s|@RABBITMQ_PORT@|'"$RABBITMQ_PORT"'|g
' /etc/rabbitmq/rabbitmq-env.conf

# For a RabbitMQ Cluster to form, all the RabbitMQ nodes
# must share the same Erlang cookie.
# Set the Erlang Cookie.
mkdir -p /var/lib/rabbitmq
echo ${RABBITMQ_ERLANG_COOKIE}  > /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
chmod 0400 /var/lib/rabbitmq/.erlang.cookie


# work around:
#   https://bugs.launchpad.net/ubuntu/+source/rabbitmq-server/+bug/653405
echo "${RABBITMQ_SERVICE_HOST} `/usr/bin/hostname -s`" >> /etc/hosts

exec /usr/sbin/rabbitmq-server
