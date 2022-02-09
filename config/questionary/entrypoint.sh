#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/questionary/questionary.jar \
    --logging.config=/opt/questionary/logback.xml \
    --management.security.flag=false \
    --management.metrics.export.statsd.enabled=false \
    --management.endpoint.health.show-details=always \
    --management.endpoint.metrics.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --spring.datasource.hikari.maximum-pool-size=20 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties

