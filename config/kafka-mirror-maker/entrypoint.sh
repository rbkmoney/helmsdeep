#!/bin/sh

set -e

exec /opt/bitnami/kafka/bin/connect-mirror-maker.sh /var/run/mm2.properties
