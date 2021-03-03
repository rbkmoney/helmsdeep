#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/fistful-magista/fistful-magista.jar \
    --logging.config=/opt/fistful-magista-kafka/logback.xml \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --spring.datasource.hikari.maximum-pool-size=20 \
    --spring.application.name=fistful-magista-kafka \
    --flyway.schemas=mst \
    --identity-management.url=http://wapi:8022/v1/identity \
    --identity-management.timeout=5000 \
    --kafka.bootstrap-servers=kafka:9092 \
    --kafka.consumer.group-id=fistful-magista \
    --kafka.consumer.concurrency=7 \
    --kafka.max-poll-records=1 \
    --kafka.max-session-timeout-ms=300000 \
    --kafka.max-poll-interval-ms=300000 \
    --kafka.topic.deposit.name=mg-events-ff-deposit \
    --kafka.topic.deposit.listener.enabled=true \
    --kafka.topic.identity.name=mg-events-ff-identity \
    --kafka.topic.identity.listener.enabled=true \
    --kafka.topic.wallet.name=mg-events-ff-wallet \
    --kafka.topic.wallet.listener.enabled=true \
    --kafka.topic.withdrawal.name=mg-events-ff-withdrawal \
    --kafka.topic.withdrawal.listener.enabled=true \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
