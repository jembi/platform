#!/bin/bash

JEMPI_KAFKA_TOPICS=(
    jempi-patient-staging-01
    jempi-patient-staging-02
    jempi-patient-staging-disi
    jempi-patient-controller
    jempi-patient-em
    jempi-patient-linker
    jempi-mu-linker
    jempi-journal
    jempi-notifications
)

for TOPIC in "${JEMPI_KAFKA_TOPICS[@]}"; do
    cd /opt/bitnami/kafka/bin || exit
    ./kafka-topics.sh \
        --bootstrap-server 127.0.0.1:9092 \
        --create \
        --replication-factor 2 \
        --partitions 1 \
        --config "retention.ms=86400000" \
        --config "segment.bytes=4194304" \
        --topic "$TOPIC"
done
