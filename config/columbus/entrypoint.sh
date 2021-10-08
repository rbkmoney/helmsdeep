#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/columbus/columbus.jar \
    --logging.file=/var/log/columbus/columbus.json \
    --logging.config=/opt/columbus/logback.xml \
    --management.security.enabled=false \
    --spring.datasource.url=jdbc:postgresql://columbus-pg:5432/columbus?sslmode=disable \
    --spring.datasource.username=postgres \
    --spring.datasource.password=postgres \
    --spring.flyway.url=jdbc:postgresql://columbus-pg:5432/columbus?sslmode=disable \
    --spring.flyway.user=postgres \
    --spring.flyway.password=postgres \
    --postgres.db.url=jdbc:postgresql://columbus-pg:5432/columbus?sslmode=disable \
    --postgres.db.user=postgres \
    --postgres.db.password=postgres \
    ${@} \
    --spring.config.additional-location=optional:/vault/secrets/application.properties

