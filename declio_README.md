# Dingo Integration with Hadoop HDFS

This document describes how to integrate the Dingo client into the Hadoop HDFS project.

## Overview

The Dingo client is a gRPC-based Java client that provides communication with the Dingo server. It has been added into the Hadoop HDFS module to enable HDFS to interact with Dingo.

## Integration Steps

### 1. Build and Install the Dingo Client

First, build the Dingo client and install it to your local Maven repository:

```bash
cd /path/to/dingo/dingo_client_java
mvn clean install -DskipTests
```

### 2. Add Dependency to Hadoop HDFS

The Dingo client dependency has already been added to the Hadoop HDFS `pom.xml`:

**File:** `hadoop-hdfs-project/hadoop-hdfs/pom.xml`
```xml
<dependency>
    <groupId>org.apache.hadoop</groupId>
    <artifactId>dingo-client</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <scope>compile</scope>
</dependency>
```

### 3. Verify the Integration

Build the Hadoop HDFS module to verify the integration:

```bash
cd /path/to/hadoop/hadoop-hdfs-project/hadoop-hdfs
mvn clean compile -DskipTests
```

If the build succeeds, the integration is complete.

### 4. Build the Complete HDFS Package

To build the complete HDFS package with the Dingo client included:

```bash
cd /path/to/hadoop/hadoop-hdfs-project/hadoop-hdfs
mvn clean package -DskipTests
```
