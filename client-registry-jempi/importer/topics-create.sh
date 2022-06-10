#!/bin/bash

set -e 
set -u

declare -a TOPICS_2x6=(
  $TOPIC_PATIENT_CONTROLLER
  $TOPIC_PATIENT_LINKER
)

declare -a TOPICS_2x1=(
  $TOPIC_PATIENT_STAGING_01
  $TOPIC_PATIENT_EM
  $TOPIC_MU_LINKER
)

RETENTION_PERIOD_MS=$((24*60*60*1000))
SEGMENT_BYTES=$((1024*1024*4))
echo "$RETENTION_PERIOD_MS"
echo "$(docker ps -q -f name=kafka-1)"

for TOPIC in ${TOPICS_2x6[@]}; do
  docker exec $(docker ps -q -f name=kafka-1) kafka-topics.sh --bootstrap-server kafka-1:9092 --create --replication-factor ${KAFKA_REPLICATION_FACTOR} --partitions 1 --topic $TOPIC 
done  

for TOPIC in ${TOPICS_2x1[@]}; do
  docker exec $(docker ps -q -f name=kafka-1) kafka-topics.sh --bootstrap-server kafka-1:9092 --create --replication-factor ${KAFKA_REPLICATION_FACTOR} --partitions 1 --topic $TOPIC 
done  

# for (( i=0; i<=4; i++ )); do
#   TOPIC=$(printf "JeMPI-TAPE-%03d" $i)
#   sleep 10
#   echo "$TOPIC"
#   docker exec $(docker ps -q -f name=kafka-1) kafka-topics.sh \
#                                      --bootstrap-server kafka-1:9092 \
#                                      --create \
#                                      --replication-factor 1 \
#                                      --partitions 1 \
#                                      --topic $TOPIC \
#                                      --config retention.ms=$RETENTION_PERIOD_MS \
#                                      --config segment.bytes=$SEGMENT_BYTES
# done
