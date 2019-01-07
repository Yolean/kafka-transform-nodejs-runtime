#!/bin/bash
set -e

runtime="$1"
[ -z "$runtime" ] && echo "Missing runtime path as first arg" && exit 1

handler="$2"
[ -z "$handler" ] && echo "Missing handler require path as second arg" && exit 1

[ -z "$BOOTSTRAP" ] && echo "Missing BOOTSTRAP env, kafka servers string" && exit 1
[ -z "$SOURCE_TOPIC" ] && echo "Missing SOURCE_TOPIC env" && exit 1
[ -z "$TARGET_TOPIC" ] && echo "Missing TARGET_TOPIC env" && exit 1
[ -z "$GROUP_ID" ] && echo "Missing GROUP_ID env" && exit 1

until kafkacat -b $BOOTSTRAP -L -t $SOURCE_TOPIC; do
  echo "Waiting for kafka $BOOTSTRAP source topic $SOURCE_TOPIC to be ready"
  sleep 1
done

until kafkacat -b $BOOTSTRAP -L -t $TARGET_TOPIC; do
  echo "Waiting for kafka $BOOTSTRAP taget topic $SOURCE_TOPIC to be ready"
  sleep 1
done

echo "Runtime: $runtime"
ls -l $runtime*
echo "Handler: $handler"
ls -l $handler*

# Unbuffered output (-u) is important for low throughput tests
node $runtime $handler -b $BOOTSTRAP -u -G $GROUP_ID $SOURCE_TOPIC \
  | kafkacat -b $BOOTSTRAP -P -t $TARGET_TOPIC
