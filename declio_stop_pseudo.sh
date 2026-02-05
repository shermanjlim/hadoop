#!/usr/bin/env bash

HADOOP_DIR=$(find hadoop-dist/target -maxdepth 1 -type d -name "hadoop-*" | head -1)
[[ -z "$HADOOP_DIR" ]] && { echo "Error: Hadoop distribution not found"; exit 1; }

cd "$HADOOP_DIR"

# Stop additional data nodes
for i in {2..5}; do
  bin/hdfs --config etc/hadoop$i --daemon stop datanode
done

# Stop HDFS
sbin/stop-dfs.sh

echo "Cluster stopped. Confirm with 'jps'"
