#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
-jar /opt/payouter/payouter.jar \
--logging.file=/var/log/payouter/payouter.json \
--logging.config=/opt/payouter/logback.xml \
--management.security.enabled=false \
-Dwoody.node_id=346 \
--service.dominant.url=http://dominant:8022/v1/domain/repository_client \
--service.shumway.url=http://shumway:8022/shumpune \
--kafka.bootstrap-servers=kafka:9092 \
--kafka.topics.invoice.enabled=false \
--kafka.topics.party-management.enabled=false \
--kafka.topics.party-management.concurrency=5 \
--kafka.client-id=payouter \
--kafka.consumer.group-id=payouter-invoicing \
--kafka.consumer.concurrency=5 \
--kafka.consumer.auto-offset-reset=latest \
${@} \
--spring.config.additional-location=/vault/secrets/application.properties
