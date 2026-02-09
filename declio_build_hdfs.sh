#!/bin/bash
# Quick build script for HDFS changes

set -e

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HADOOP_ROOT="${HADOOP_ROOT:-$SCRIPT_DIR}"
DIST_DIR=$(find "$HADOOP_ROOT/hadoop-dist/target" -maxdepth 1 -type d -name "hadoop-*" | head -n 1)

echo "==> Building hadoop-hdfs..."
cd "$HADOOP_ROOT/hadoop-hdfs-project/hadoop-hdfs"
mvn package -DskipTests -Dmaven.javadoc.skip=true

echo "==> Copying new JAR to distribution..."
cp target/hadoop-hdfs-*.jar $DIST_DIR/share/hadoop/hdfs/
