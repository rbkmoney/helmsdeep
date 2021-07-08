#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/wb-list-manager/wb-list-manager.jar \
    --logging.config=/opt/wb-list-manager/logback.xml \
    --logging.file=/var/log/wb-list-manager/wb-list-manager.json \
    --management.security.enabled=false \
    --riak.address=riak \
    --riak.port=8087 \
    --kafka.bootstrap.servers=kafka:9092 \
    --management.metrics.export.statsd.enabled=false \
    ${@}

