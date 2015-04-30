#!/bin/bash

set -ex

: ${LOGSTASH_CERTIFICATE_NODE_IP:=172.29.84.151}
: ${LOGSTASH_CERTIFICATE_NODE_PORT:=7777}
: ${LOGSERVER_NODE_IP:=172.29.84.151}
: ${LOGSERVER_NODE_PORT:=5000}

echo "Creating Cert directories"
mkdir -p /etc/pki/tls/certs

echo "Download logstash certificates "
wget http://${LOGSTASH_CERTIFICATE_NODE_IP}:${LOGSTASH_CERTIFICATE_NODE_PORT}/logstash-forwarder.crt

echo "Copy certificate to cert directory "
cp logstash-forwarder.crt /etc/pki/tls/certs/

echo "Edit the config file"
sed -i '
        s|@LOGSERVER_NODE_IP@|'"$LOGSERVER_NODE_IP"'|g
        s|@LOGSERVER_NODE_PORT@|'"$LOGSERVER_NODE_PORT"'|g
' /logstash-forwarder.conf

echo "Copy the config file to /etc/"
cp logstash-forwarder.conf /etc/logstash-forwarder.conf 

echo "START LOGSTASH FORWARDING "  
#/etc/init.d/logstash-forwarder start
/opt/logstash-forwarder/bin/logstash-forwarder -config /etc/logstash-forwarder.conf   
