#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/columbus/columbus.jar \
    --logging.config=/opt/columbus/logback.xml \
    --management.security.enabled=false \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --spring.datasource.url=jdbc:postgresql://columbus-pg:5432/columbus?sslmode=disable \
    --spring.datasource.username=postgres \
    --spring.datasource.password=postgres \
    --spring.flyway.url=jdbc:postgresql://columbus-pg:5432/columbus?sslmode=disable \
    --spring.flyway.user=postgres \
    --spring.flyway.password=postgres \
    --geo.db.file.path=classpath:GeoLite2-City.mmdb \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties

