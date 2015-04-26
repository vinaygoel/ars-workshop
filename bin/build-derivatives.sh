#!/usr/bin/env bash
set -e

if [ $# != 3 ] ; then
    echo "usage: $0 <LOCAL_WARC_DIR> <LOCAL_DERIVATIVE_DIR> <HDFS_WORKING_DIR>"
    echo "LOCAL_WARC_DIR: Local directory where WARCs are stored"
    echo "LOCAL_DERIVATIVE_DIR: Local (empty / new) directory where the built derivatives will be copied to"
    echo "HDFS_WORKING_DIR: HDFS directory where WARCs and derivatives will be stored"
    exit 1
fi

LOCAL_WARC_DIR=$1
LOCAL_DERIVATIVE_DIR=$2
HDFS_WORKING_DIR=$3

BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../

if [ -z "$JAVA_HOME" ]; then
    echo "Please set JAVA_HOME"
    exit 2
fi

if [ -z "$HADOOP_HOME" ]; then
    echo "Please set HADOOP_HOME"
    exit 3
fi

if [ -z "$PIG_HOME" ]; then
    echo "Please set PIG_HOME"
    exit 4
fi

if [ ! "$(ls $LOCAL_WARC_DIR/*arc.gz)" ]; then
  echo "No WARC files found under LOCAL_WARC_DIR ($LOCAL_WARC_DIR) !!"
  exit 5
fi

mkdir -p $LOCAL_DERIVATIVE_DIR

#if [ "$(ls -A $LOCAL_DERIVATIVE_DIR)" ]; then
#     echo "LOCAL_DERIVATIVE_DIR ($LOCAL_DERIVATIVE_DIR) is not empty!"
#     exit 6
#fi

HDFS_WARC_DIR=$HDFS_WORKING_DIR/warcs/
HDFS_DERIVATIVE_DIR=$HDFS_WORKING_DIR/derivatives/

HDFS_CDX_DIR=$HDFS_DERIVATIVE_DIR/cdx/
HDFS_WAT_DIR=$HDFS_DERIVATIVE_DIR/wat/
HDFS_PARSED_DIR=$HDFS_DERIVATIVE_DIR/parsed/
HDFS_WANE_DIR=$HDFS_DERIVATIVE_DIR/wane/
HDFS_LGA_DIR=$HDFS_DERIVATIVE_DIR/lga/

echo "Creating working directories in HDFS..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p $HDFS_WARC_DIR
$HADOOP_HOME/bin/hdfs dfs -mkdir -p $HDFS_DERIVATIVE_DIR

echo "Uploading WARC files into HDFS..."

$HADOOP_HOME/bin/hdfs dfs -put $LOCAL_WARC_DIR/*arc.gz $HDFS_WARC_DIR

echo "Building derivatives in Hadoop..."

echo "1) CDX..."

$HADOOP_HOME/bin/hadoop jar $BASE_DIR/lib/ia-hadoop-tools-jar-with-dependencies.jar \
                            CDXGenerator -soft $HDFS_CDX_DIR $HDFS_WARC_DIR/*arc.gz

echo "2) Parsed Text..."

$HADOOP_HOME/bin/hadoop jar $BASE_DIR/lib/jbs.jar org.archive.jbs.Parse \
                            -conf $BASE_DIR/etc/job-parse.xml \
                            $HDFS_PARSED_DIR $HDFS_WARC_DIR/*arc.gz

echo "3) WAT..."

$HADOOP_HOME/bin/hadoop jar $BASE_DIR/lib/ia-hadoop-tools-jar-with-dependencies.jar \
                            WATGenerator -soft $HDFS_WAT_DIR $HDFS_WARC_DIR/*arc.gz

echo "4) WANE..."

CLASSIFIER=english.all.3class.distsim.crf.ser.gz
# upload classifier to HDFS (if not already there)
if ! $HADOOP_HOME/bin/hdfs dfs -test -e "/tmp/$CLASSIFIER"; then
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp/
    $HADOOP_HOME/bin/hdfs dfs -put $BASE_DIR/lib/$CLASSIFIER /tmp/
fi

$PIG_HOME/bin/pig -Dmapred.cache.files="/tmp/$CLASSIFIER#$CLASSIFIER" \
                  -Dmapred.create.symlink=yes \
                  -p I_NER_CLASSIFIER_FILE=$CLASSIFIER \
                  -p I_PARSED_DATA_DIR=$HDFS_PARSED_DIR \
                  -p O_ENTITIES_DIR=$HDFS_WANE_DIR \
                  $BASE_DIR/pig/extract-entities.pig

echo "5) LGA..."

$PIG_HOME/bin/pig -p I_PARSED_DATA_DIR=$HDFS_PARSED_DIR \
                  -p I_CDX_DATA_DIR=$HDFS_CDX_DIR \
                  -p O_GRAPH_DATA_DIR=$HDFS_LGA_DIR \
                  $BASE_DIR/pig/generate-id-map-and-graph.pig

echo "Done building derivatives in Hadoop!"

echo "Downloading derivatives to local directory..."
$HADOOP_HOME/bin/hdfs dfs -get $HDFS_DERIVATIVE_DIR/ $LOCAL_DERIVATIVE_DIR/

echo "Derivatives available in $LOCAL_DERIVATIVE_DIR (local) and $HDFS_DERIVATIVE_DIR (HDFS)"
