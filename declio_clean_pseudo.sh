#!/usr/bin/env bash

# WARNING: Removes all /tmp/hadoop* files
rm -rf /tmp/hadoop*

HADOOP_DIR=$(find hadoop-dist/target -maxdepth 1 -type d -name "hadoop-*" | head -1)
[[ -z "$HADOOP_DIR" ]] && { echo "Error: Hadoop distribution not found"; exit 1; }

cd "$HADOOP_DIR"

# Clean logs
rm -rf logs
mkdir logs
chmod 777 logs

echo "Cleanup complete"
