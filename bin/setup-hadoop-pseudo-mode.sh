#!/usr/bin/env bash
set -e

if [ $# != 2 ] ; then
    echo "usage: $0 <HADOOP_INSTALL_DIR> <PIG_INSTALL_DIR>"
    echo "HADOOP_INSTALL_DIR: Local directory where Hadoop will be installed"
    echo "PIG_INSTALL_DIR: Local directory where Pig will be installed"
    exit 1
fi

HADOOP_INSTALL_DIR=$1
PIG_INSTALL_DIR=$2

#hadoop install
INSTALL_DIR=$HADOOP_INSTALL_DIR
USER_NAME=`whoami`
hadoop_version=hadoop-2.6.0
hadoop_stable_mirror=http://mirror.nexcess.net/apache/hadoop/common/stable/$hadoop_version.tar.gz

if [ -z "$JAVA_HOME" ]; then
    echo "Please set JAVA_HOME"
    exit 2
fi

if [ -d "$HADOOP_INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $HADOOP_INSTALL_DIR"
  exit 3
fi

if [ -d "$PIG_INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $PIG_INSTALL_DIR"
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

echo "=============================================================================================="
echo "Browse the web interface for the Namenode: http://localhost:50070/  -- enter a key to continue"
echo "=============================================================================================="
read continueInput

echo "Testing execution of simple MapReduce job"
bin/hdfs dfs -mkdir -p /user/$USER_NAME
bin/hdfs dfs -put etc/hadoop input
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar grep input output 'dfs[a-z.]+'
bin/hdfs dfs -get output output
cat output/*

echo "MapReduce job test run completed"

#pig install
INSTALL_DIR=$PIG_INSTALL_DIR
pig_version=pig-0.14.0
pig_stable_mirror=http://apache.mirrors.hoobly.com/pig/$pig_version/$pig_version.tar.gz

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "Downloading Pig"
curl -O $pig_stable_mirror

echo "Installing Pig"
tar xfvz $pig_version.tar.gz
echo "Pseudo Distributed Mode installation done!"

