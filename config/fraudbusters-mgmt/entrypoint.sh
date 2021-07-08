#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/fraudbusters-management/fraudbusters-management.jar \
    --logging.config=/opt/fraudbusters-management/logback.xml \
    --management.security.enabled=false \
    --kafka.ssl.enable=false \
    --kafka.bootstrap.servers=kafka:9092 \
    --service.payment.url=http://fraudbusters:8022/fraud_payment/v1/ \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties
