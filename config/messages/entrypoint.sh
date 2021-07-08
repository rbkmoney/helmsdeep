#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
        /opt/messages/messages.jar \
          --logging.file=/var/log/messages/messages.json \
          --logging.config=/opt/messages/logback.xml \
          -Dwoody.node_id=1 \
          --spring.datasource.url=jdbc:postgresql://postgres-postgresql:5432/messages?sslmode=disable \
          --spring.datasource.username=postgres \
          --spring.datasource.password=H@ckM3 \
          --spring.flyway.url=jdbc:postgresql://postgres-postgresql:5432/messages?sslmode=disable \
          --spring.flyway.user=postgres \
          --spring.flyway.password=H@ckM3 \
          --spring.flyway.schemas=msgs \
          --flyway.schemas=msgs \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties
