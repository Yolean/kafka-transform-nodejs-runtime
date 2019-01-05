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

# having some kind of timing issue, transform won't happen if this runs prior to runtime start
sleep 10

echo "{\"test\":\"$(date)\"}" | kafkacat -b $BOOTSTRAP -P -t $SOURCE_TOPIC
# Assuming that test topic was empty this will only exit if the transform produced an output message
kafkacat -b $BOOTSTRAP -C -t $TARGET_TOPIC -c 1 -u
