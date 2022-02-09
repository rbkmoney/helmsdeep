#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/columbus/columbus.jar \
    --logging.config=/opt/columbus/logback.xml \
    --management.security.enabled=false \
    --management.metrics.export.statsd.enabled=false \
    --management.endpoint.health.show-details=always \
    --management.endpoint.metrics.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --spring.datasource.url=jdbc:postgresql://columbus-pg:5432/columbus?sslmode=disable \
    --spring.datasource.username=postgres \
    --spring.datasource.password=postgres \
    --spring.flyway.url=jdbc:postgresql://columbus-pg:5432/columbus?sslmode=disable \
    --spring.flyway.user=postgres \
    --spring.flyway.password=postgres \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties

