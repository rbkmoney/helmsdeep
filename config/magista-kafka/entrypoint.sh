#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/magista-kafka/magista-kafka.jar \
    --logging.config=/opt/magista-kafka/logback.xml \
    --spring.application.name=magista-kafka \
    --spring.datasource.hikari.maximum-pool-size=mg-events-invoice \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --flyway.schemas=mst \
    --payouter.pooling.url=http://payouter:8022/repo \
    --hellgate.url=http://hellgate:8022/v1/processing/partymgmt \
    --hellgate.timeout=30000 \
    --columbus.url=http://columbus:8022/repo \
    --retry-policy.maxAttempts=-1 \
    --kafka.bootstrap-servers=kafka-headless:9092 \
    --kafka.topics.invoicing=mg-events-invoice \
    --kafka.client-id=magista \
    --kafka.consumer.group-id=magista-invoicing-1 \
    --kafka.consumer.concurrency=7 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
