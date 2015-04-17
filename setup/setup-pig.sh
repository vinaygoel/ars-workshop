#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: setup-pig.sh <PIG_INSTALL_DIR>"
    echo "PIG_INSTALL_DIR: Local directory where Pig will be installed"
    exit 1
fi

INSTALL_DIR=$1
USER_NAME=`whoami`
pig_version=pig-0.14.0
pig_stable_mirror=http://apache.mirrors.hoobly.com/pig/$pig_version/$pig_version.tar.gz

if [ -z "$JAVA_HOME" ]; then
    echo "Please set JAVA_HOME"
    exit 2
fi

if [ -z "$HADOOP_HOME" ]; then
    echo "Please set HADOOP_HOME"
    exit 3
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $INSTALL_DIR"
  exit 4
fi

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "Downloading Pig"
curl -O $pig_stable_mirror

echo "Installing Pig"
tar xfvz $pig_version.tar.gz
export PIG_HOME=$INSTALL_DIR/$pig_version
#export PATH=$PIG_HOME/bin:$PATH


echo "Apache Pig has been set up"

echo "==========================================================="
echo "Please set PIG_HOME to $PIG_HOME: export PIG_HOME=$PIG_HOME"
echo "Please add Pig to your path: export PATH=$PIG_HOME/bin:\$PATH";
echo "==========================================================="


