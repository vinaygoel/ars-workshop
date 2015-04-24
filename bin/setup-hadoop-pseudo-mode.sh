#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <HADOOP_INSTALL_DIR>"
    echo "HADOOP_INSTALL_DIR: Local directory where Hadoop will be installed"
    exit 1
fi

INSTALL_DIR=$1
USER_NAME=`whoami`
hadoop_version=hadoop-2.6.0
hadoop_stable_mirror=http://mirror.nexcess.net/apache/hadoop/common/stable/$hadoop_version.tar.gz

if [ -z "$JAVA_HOME" ]; then
    echo "Please set JAVA_HOME"
    exit 2
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $INSTALL_DIR"
  exit 3
fi

if [ -d "/tmp/hadoop-$USER_NAME" ]; then
  echo "Please delete this directory (from prior install): /tmp/hadoop-$USER_NAME"
  exit 4
fi

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "Downloading Hadoop"
curl -O $hadoop_stable_mirror

echo "Installing Hadoop"
tar xfvz $hadoop_version.tar.gz
export HADOOP_HOME=$INSTALL_DIR/$hadoop_version
cd $HADOOP_HOME

echo "Setting up configuration for Pseudo-Distributed Operation"
# overwrite core-site.xml
(
cat << 'CORE-SITE'
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
CORE-SITE
) > etc/hadoop/core-site.xml

#overwrite hdfs-site.xml
(
cat << 'HDFS-SITE'
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
HDFS-SITE
) > etc/hadoop/hdfs-site.xml

echo "Formatting HDFS"
bin/hdfs namenode -format

echo "Starting NameNode daemon and DataNode daemon"
sbin/start-dfs.sh

echo "Browse the web interface for the Namenode: http://localhost:50070/"
echo "Enter any key to continue..."
read continueInput

echo "Testing execution of simple MapReduce job"
bin/hdfs dfs -mkdir -p /user/$USER_NAME
bin/hdfs dfs -put etc/hadoop input
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar grep input output 'dfs[a-z.]+'
bin/hdfs dfs -get output output
cat output/*

echo "MapReduce job test run completed"
echo "Hadoop Pseudo Distributed Mode has been set up"

echo "==========================================================="
echo "Please set HADOOP_HOME to $HADOOP_HOME: export HADOOP_HOME=$HADOOP_HOME"
echo "To stop all Hadoop daemons, run $HADOOP_HOME/sbin/stop-dfs.sh"
echo "==========================================================="
