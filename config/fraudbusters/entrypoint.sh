#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/fraudbusters/fraudbusters.jar \
    --logging.config=/opt/fraudbusters/logback.xml \
    --management.security.enabled=false \
    --geo.ip.service.url=http://columbus:8022/repo \
    --kafka.ssl.enable=false \
    --kafka.bootstrap.servers=kafka:9092 \
    --wb.list.service.url=http://wb-list-manager:8022/v1/wb_list \
    --clickhouse.db.url=jdbc:clickhouse://chi-demo-cluster-0-0:8123/fraud \
    --clickhouse.db.user=fraud \
    --clickhouse.db.password=hackme \
    --fraud.management.url=http://fraudbusters-mgmt:8022 \
    --spring.profiles.active=full-prod \
    --kafka.topic.event.sink.payment=payment_event \
    --kafka.topic.event.sink.refund=refund_event \
    --kafka.topic.event.sink.chargeback=chargeback_event \
    ${@}

