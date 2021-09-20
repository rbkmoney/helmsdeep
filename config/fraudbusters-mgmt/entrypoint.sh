#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/fraudbusters-management/fraudbusters-management.jar \
    --logging.config=/opt/fraudbusters-management/logback.xml \
    --logging.file=/var/log/fraudbusters-management/fraudbusters-management.json \
    --kafka.bootstrap.servers=kafka:9092 \
    --kafka.topic.wblist.command=wb-list-command \
    --kafka.topic.wblist.topic.event.sink=wb-list-event-sink \
    --kafka.topic.fraudbusters.payment.template=fraud-template-command\
    --kafka.topic.fraudbusters.payment.reference=fraud-template-reference-command\
    --kafka.topic.fraudbusters.payment.group.list=fraud-group-list-command\
    --kafka.topic.fraudbusters.payment.group.reference=fraud-group-reference-command\
    --kafka.topic.fraudbusters.p2p.template=fraud-p2p-template-command\
    --kafka.topic.fraudbusters.p2p.reference=fraud-p2p-template-reference-command\
    --kafka.topic.fraudbusters.p2p.group.list=fraud-p2p-group-list-command\
    --kafka.topic.fraudbusters.p2p.group.reference=fraud-p2p-group-reference-command\
    --kafka.topic.fraudbusters.unknown-initiating-entity=fraud-unknown-initiating-entity\
    # TODO: vault?
#    {% if kafka.ssl.get('enable', False) %}
#    --kafka.ssl.keystore-location=/opt/fraudbusters-management/kafka-keystore.p12 \
#    --kafka.ssl.keystore-password="{{ service.keystore.pass }}" \
#    --kafka.ssl.key-password="{{ service.keystore.pass }}" \
#    --kafka.ssl.server-keystore-location=/opt/fraudbusters-management/kafka-truststore.p12 \
#    --kafka.ssl.server-password="{{ kafka.truststore.java.pass }}" \
#    --kafka.ssl.enable=false \
#    {% endif %}
    --management.security.enabled=false \
    --management.endpoint.metrics.enabled=true \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoint.health.show-details=always \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --service.payment.url=http://fraudbusters-p2p:8022/fraud_payment/v1/ \
    --service.historical.url=http://fraudbusters-p2p:8022/historical_data/v1/ \
    --service.p2p.url=http://fraudbusters-p2p:8022/fraud_p2p/v1/ \
    --service.cleaner.fresh-period=30 \
    --service.notification.url=http://fraudbusters-notificator:8022/notification/v1 \
    --service.notification-channel.url=http://fraudbusters-notificator:8022/notification-channel/v1 \
    --service.notification-template.url=http://fraudbusters-notificator:8022/notification-template/v1 \
    --keycloak.enabled=true \
    --keycloak.realm=internal \
    --keycloak.ssl-required=none \
    --keycloak.resource=fraudbusters-app \
    --keycloak.auth-server-url=https://auth.{{ .Release.Namespace }}.{{ .Values.services.ingress.rootDomain | default "rbk.dev" }}/auth \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties
