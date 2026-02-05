#!/usr/bin/env bash

HADOOP_DIR=$(find hadoop-dist/target -maxdepth 1 -type d -name "hadoop-*" | head -1)
[[ -z "$HADOOP_DIR" ]] && { echo "Error: Hadoop distribution not found"; exit 1; }

cd "$HADOOP_DIR"

# Start cluster
bin/hdfs namenode -format
sbin/start-dfs.sh

# Start additional data nodes
for i in {2..5}; do
  bin/hdfs --config etc/hadoop$i --daemon start datanode
done

# Create test file
bin/hdfs dfs -mkdir -p /test
bin/hdfs dfs -rm -f /test/tmp.txt
bin/hdfs dfs -touchz /test/tmp.txt
dd if=/dev/zero of=tmp.dat bs=128M count=1 2>/dev/null
bin/hdfs dfs -appendToFile tmp.dat /test/tmp.txt
rm tmp.dat

# Set up erasure coding
bin/hdfs ec -enablePolicy -policy RS-3-2-1024k
bin/hdfs dfs -mkdir -p /.transcoded
bin/hdfs ec -setPolicy -path /.transcoded -policy RS-3-2-1024k

echo "Cluster started. Use 'bin/hdfs dfsadmin -report' to check status"
