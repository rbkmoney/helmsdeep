#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/fraudbusters-notificator/fraudbusters-notificator.jar \
    --logging.config=/opt/fraudbusters-notificator/logback.xml \
    --management.security.enabled=false \
    --management.endpoint.metrics.enabled=true \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoint.health.show-details=always \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --warehouse.url=http://fraudbusters-warehouse:8022/query/v1/ \
    --fixedDelay.in.milliseconds="600000" \
    --mail.host=mr1.linode.rbkmoney.net \
    --mail.port=25 \
    --mail.username="" \
    --mail.password="" \
    --mail.protocol=smtp \
    --mail.smtp.auth=false \
    --mail.smtp.timeout=30000 \
    --mail.smtp.from-address="NotificationService@rbkmoney.com" \
    --mail.smtp.starttls.enable=true \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties