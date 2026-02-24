#!/usr/bin/env bash
set -euo pipefail

# Declares a file transcoding to Dingo, waits for scheduling, then moves
# the file to a new HDFS path whose directory determines the EC policy.
#
# Usage: declio_transcode.sh <src> <dst> [dingo_addr] [deadline_secs]

if [[ $# -lt 2 || $# -gt 4 ]]; then
  echo "Usage: $0 <src> <dst> [dingo_addr] [deadline_secs]"
  exit 1
fi

SRC="$1"
DST="$2"
DINGO_ADDR="${3:-localhost:50051}"
DEADLINE_SECS="${4:-3}"

HDFS="hadoop-dist/target/hadoop-3.4.2/bin/hdfs"
DECLARE="../dingo/build/examples/declare_transcode"

NUM_BYTES=$("$HDFS" dfs -du "$SRC" | awk '{print $1}')

"$DECLARE" "$DINGO_ADDR" "$SRC" 0 "$NUM_BYTES" "$DEADLINE_SECS"

"$HDFS" dfs -cp "$SRC" "$DST"
"$HDFS" dfs -rm "$SRC"

echo "Done. Verify: $HDFS ec -getPolicy -path $DST"
