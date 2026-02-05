#!/usr/bin/env bash

HADOOP_DIR=$(find hadoop-dist/target -maxdepth 1 -type d -name "hadoop-*" | head -1)
[[ -z "$HADOOP_DIR" ]] && { echo "Error: Hadoop distribution not found"; exit 1; }

cd "$HADOOP_DIR"

mkdir -p logs && chmod 777 logs

cd etc/hadoop

# Set environment variables
cat >> hadoop-env.sh <<'EOF'
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_YARN_HOME=${HADOOP_HOME}
export HADOOP_MAPRED_HOME=${HADOOP_HOME}
EOF

# Configure core-site.xml
sed -i '/<configuration>/a \
<property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property>' \
core-site.xml

# Configure hdfs-site.xml
sed -i '/<configuration>/a\
<property><name>dfs.datanode.data.dir</name><value>file://${hadoop.tmp.dir}/dfs/data1</value></property>\n\
<property><name>dfs.datanode.address</name><value>0.0.0.0:9900</value></property>\n\
<property><name>dfs.datanode.http.address</name><value>0.0.0.0:9901</value></property>\n\
<property><name>dfs.datanode.ipc.address</name><value>0.0.0.0:9902</value></property>' \
hdfs-site.xml

cd ../..

# Set up additional data nodes
for i in {2..5}; do
  cp -r etc/hadoop etc/hadoop$i
  cd etc/hadoop$i
  echo "export HADOOP_PID_DIR=/tmp/hadoop${i}" >> hadoop-env.sh
  echo "export HADOOP_LOG_DIR=\${HADOOP_HOME}/logs/hadoop${i}" >> hadoop-env.sh
  sed -i "0,/data1/{s/data1/data${i}/}" hdfs-site.xml
  sed -i "s/990/99${i}/g" hdfs-site.xml
  cd ../..
done

echo "Setup complete"
