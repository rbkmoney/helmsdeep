#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/fraudbusters-warehouse/fraudbusters-warehouse.jar \
    --logging.config=/opt/fraudbusters-warehouse/logback.xml \
    --management.security.enabled=false \
    --management.endpoint.metrics.enabled=true \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoint.health.show-details=always \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    ${@} \
    --spring.config.additional-location=/var/lib/fraudbusters-warehouse/additional.ch.properties

