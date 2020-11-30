#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/shumway/shumway.jar \
    --logging.config=/opt/shumway/logback.xml \
    --spring.flyway.table=schema_version \
    --spring.flyway.schemas=shm \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties
