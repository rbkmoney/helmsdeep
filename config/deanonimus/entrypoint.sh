#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
        /opt/deanonimus/deanonimus.jar \
        --logging.file=/var/log/deanonimus/deanonimus.json \
        --logging.config=/opt/deanonimus/logback.xml \
        --spring.elasticsearch.rest.uris="deanonimus-es:9200" \
        --spring.elasticsearch.rest.connection-timeout=5s \
        --kafka.bootstrap-servers="kafka:9092" \
        --kafka.client-id=deanonimus \
        --kafka.topics.party-management.id=mg-events-party \
        --kafka.topics.party-management.enabled=true \
        --kafka.topics.party-management.consumer.group-id=deanonimus-group-1 \
        --kafka.consumer.party-management.concurrency=7 \
        --kafka.consumer.auto-offset-reset=earliest \
        --kafka.error-handler.sleep-time-seconds=5 \
        --kafka.error-handler.maxAttempts=-1 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
