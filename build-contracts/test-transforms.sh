#!/bin/bash
set -e

[ -z "$BOOTSTRAP" ] && echo "Missing BOOTSTRAP env, kafka servers string" && exit 1
[ -z "$SOURCE_TOPIC" ] && echo "Missing SOURCE_TOPIC env" && exit 1
[ -z "$TARGET_TOPIC" ] && echo "Missing TARGET_TOPIC env" && exit 1

until kafkacat -b $BOOTSTRAP -L -t $SOURCE_TOPIC; do
  echo "Waiting for kafka $BOOTSTRAP source topic $SOURCE_TOPIC to be ready"
  sleep 3
done

set -x
echo "{\"test\":\"$(date)\"}" | kafkacat -b $BOOTSTRAP -P -t $SOURCE_TOPIC
# Assuming that test topic was empty
kafkacat -b $BOOTSTRAP -C -t $TARGET_TOPIC -c 1

echo "{\"test\":\"$(date)\"}" | kafkacat -b $BOOTSTRAP -P -t $SOURCE_TOPIC
sleep 1
echo "{\"test\":\"$(date)\"}" | kafkacat -b $BOOTSTRAP -P -t $SOURCE_TOPIC
sleep 1
kafkacat -b $BOOTSTRAP -C -t $TARGET_TOPIC -o -2 -e
