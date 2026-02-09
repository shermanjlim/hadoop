#!/bin/bash
set -e

# Set required environment variables
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export MAVEN_OPTS="-Xms256m -Xmx1536m"

# Default to 'package', add 'clean' if passed as an argument
MVN_GOALS="package"
[[ "$1" == "clean" || "$1" == "--clean" ]] && MVN_GOALS="clean package"

# Temporarily disable YARN catalog (prevents build failures if Node.js/Yarn aren't installed)
YARN_POM="hadoop-yarn-project/hadoop-yarn/hadoop-yarn-applications/pom.xml"
if [[ -f "$YARN_POM" ]]; then
    cp "$YARN_POM" "$YARN_POM.backup"
    sed -i 's/<module>hadoop-yarn-applications-catalog<\/module>//' "$YARN_POM"
fi

# Execute the streamlined Maven build
mvn $MVN_GOALS -Pdist -Dtar -DskipTests -Dmaven.javadoc.skip=true -Denforcer.skip=true

# Restore the original POM
[[ -f "$YARN_POM.backup" ]] && mv "$YARN_POM.backup" "$YARN_POM"

echo -e "\nBuild complete! Check hadoop-dist/target/ for your tarball."
