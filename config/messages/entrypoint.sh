#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
        /opt/messages/messages.jar \
          --logging.file=/var/log/messages/messages.json \
          --logging.config=/opt/messages/logback.xml \
          -Dwoody.node_id=1 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties
