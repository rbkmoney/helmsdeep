#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/hooker/hooker.jar \
    --logging.config=/opt/hooker/logback.xml \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --spring.datasource.hikari.maximum-pool-size=20 \
    --kafka.bootstrap-servers=kafka:9092 \
    --kafka.topics.invoice.enabled=true \
    --kafka.topics.customer.enabled=true \
    --kafka.topics.invoice.concurrency=7 \
    --kafka.topics.customer.concurrency=2 \
    --kafka.topics.invoice.id=mg-events-invoice \
    --kafka.topics.customer.id=mg-events-customer \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \

