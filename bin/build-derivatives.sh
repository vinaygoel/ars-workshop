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

#TODO: upload warcs
#call different derive scripts
#download derivatives

#do it all in this script?


