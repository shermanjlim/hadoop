#!/usr/bin/env bash

HADOOP_DIR=$(find hadoop-dist/target -maxdepth 1 -type d -name "hadoop-*" | head -1)
[[ -z "$HADOOP_DIR" ]] && { echo "Error: Hadoop distribution not found"; exit 1; }

# Convert to absolute path
ABS_HADOOP_DIR=$(cd "$HADOOP_DIR" && pwd)
cd "$ABS_HADOOP_DIR"

mkdir -p logs && chmod 777 logs

# 3. Define Reserved Values (index 1-5 correspond to dn1-dn5)
RESERVED=(0 10737418240 10737418240 21474836480 10737418240 10737418240)

# 4. Configuration Function to prevent code duplication
configure_node() {
    local node_id=$1
    local conf_dir=$2
    local reserved_val=$3
    
    mkdir -p "$conf_dir"
    
    # Create a fresh hadoop-env.sh
    cat > "$conf_dir/hadoop-env.sh" <<EOF
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_HOME=$ABS_HADOOP_DIR
export HADOOP_YARN_HOME=\$HADOOP_HOME
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_PID_DIR=/tmp/hadoop${node_id}
export HADOOP_LOG_DIR=\$HADOOP_HOME/logs/hadoop${node_id}
EOF

    # Create a fresh core-site.xml
    cat > "$conf_dir/core-site.xml" <<EOF
<configuration>
    <property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property>
</configuration>
EOF

    # Create a fresh hdfs-site.xml with dynamic ports
    cat > "$conf_dir/hdfs-site.xml" <<EOF
<configuration>
    <property><name>dfs.datanode.address</name><value>0.0.0.0:99${node_id}0</value></property>
    <property><name>dfs.datanode.http.address</name><value>0.0.0.0:99${node_id}1</value></property>
    <property><name>dfs.datanode.ipc.address</name><value>0.0.0.0:99${node_id}2</value></property>
    <property><name>dfs.datanode.data.dir</name><value>file:///tmp/hdfs/dn${node_id}</value></property>
    <property><name>dfs.datanode.du.reserved</name><value>${reserved_val}</value></property>
</configuration>
EOF
}

# 5. Execute for DN1
configure_node 1 "etc/hadoop" ${RESERVED[1]}

# 6. Execute for DN2-5
for i in {2..5}; do
    configure_node $i "etc/hadoop$i" ${RESERVED[$i]}
done

# 7. Cleanup and create data dirs
rm -rf /tmp/hdfs/dn{1..5}
mkdir -p /tmp/hdfs/dn{1..5}

echo "Setup complete in $ABS_HADOOP_DIR"