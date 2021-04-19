#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/wallets-hooker/wallets-hooker.jar \
    --logging.config=/opt/wallets-hooker/logback.xml \
    --management.security.flag=false \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --management.endpoint.health.show-details=always \
    --management.endpoint.metrics.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --spring.datasource.hikari.data-source-properties.prepareThreshold=0 \
    --spring.datasource.hikari.leak-detection-threshold=5300 \
    --spring.datasource.hikari.max-lifetime=300000 \
    --spring.datasource.hikari.idle-timeout=30000 \
    --spring.datasource.hikari.minimum-idle=2 \
    --spring.datasource.hikari.maximum-pool-size=20 \
    --spring.flyway.schemas=whook \
    --spring.application.name=wallets-hooker \
    --webhook.sender.enabled=false \
    --kafka.bootstrap-servers=kafka:9092 \
    --kafka.consumer.group-id=wallets-hooker \
    --kafka.consumer.concurrency=7 \
    --kafka.topic.hook.name=webhooks \
    --kafka.topic.destination.name=mg-events-ff-destination \
    --kafka.topic.destination.listener.enabled=true \
    --kafka.topic.wallet.name=mg-events-ff-wallet \
    --kafka.topic.wallet.listener.enabled=true \
    --kafka.topic.withdrawal.name=mg-events-ff-withdrawal \
    --kafka.topic.withdrawal.listener.enabled=true \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
