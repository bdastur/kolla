#!/bin/bash

: ${MEMCACHED_USER:=memcached}
: ${MEMCACHED_PORT:=11211}
: ${CACHESIZE:=64}
: ${CONNS:=1024}

CMD="/usr/bin/memcached"
ARGS="-u ${MEMCACHED_USER} -p ${MEMCACHED_PORT} -m ${CACHESIZE} -c ${CONNS}"

exec $CMD $ARGS 
