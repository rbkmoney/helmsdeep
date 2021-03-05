#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/claim-management/claim-management.jar \
    --logging.config=/opt/claim-management/logback.xml \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --spring.datasource.hikari.maximum-pool-size=20 \
    --spring.application.name=claim-management \
    --claim-management.limit=1000 \
    --kafka.bootstrap.servers=kafka:9092 \
    --kafka.topics.claim-event-sink.enabled=true \
    --kafka.topics.claim-event-sink.id=claim-event-sink \
    --kafka.client-id=claim-management \
    --kafka.consumer.group-id=claim-management-group-1 \
    --claim-management.committers[0].id=hellgate \
    --claim-management.committers[0].uri=http://hellgate:8022/v1/processing/claim_committer \
    --claim-management.committers[0].timeout=60000 \
    --claim-management.committers[1].id=cashier \
    --claim-management.committers[1].uri=http://cashier:8022/claim-committer \
    --claim-management.committers[1].timeout=10000 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
