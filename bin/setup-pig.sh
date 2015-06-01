#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <HADOOP_PIG_LOCAL_INSTALL_DIR>"
    echo "HADOOP_PIG_LOCAL_INSTALL_DIR: Local directory where Hadoop & Pig will be installed"
    exit 1
fi

HADOOP_PIG_LOCAL_INSTALL_DIR=$1

if [ -d "$HADOOP_PIG_LOCAL_INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $HADOOP_PIG_LOCAL_INSTALL_DIR"
  exit 2
fi

mkdir -p $HADOOP_PIG_LOCAL_INSTALL_DIR
cd $HADOOP_PIG_LOCAL_INSTALL_DIR

echo "Downloading Hadoop & Pig"
curl -O http://archive.org/~vinay/archive-analysis/hadoop-2-local-mode.tar.gz

echo "Installing Hadoop & Pig"
tar xfz hadoop-2-local-mode.tar.gz

echo "Local Mode installation done!"

