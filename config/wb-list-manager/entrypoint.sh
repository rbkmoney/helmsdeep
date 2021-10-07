#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/wb-list-manager/wb-list-manager.jar \
    --logging.config=/opt/wb-list-manager/logback.xml \
    --management.security.enabled=false \
    --riak.address=riak \
    --riak.port=8087 \
    --riak.bucket=wblist \
    --retry.timeout=2000 \
    --retry.max.attempts=3 \
    --kafka.bootstrap-servers=kafka:9092 \
    --kafka.wblist.topic.command=wb-list-command \
    --kafka.wblist.topic.event.sink=wb-list-event-sink \
    --kafka.ssl.enable=false \
    --management.metrics.export.statsd.enabled=false \
    ${@}

