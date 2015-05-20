#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <PIG_INSTALL_DIR>"
    echo "PIG_INSTALL_DIR: Local directory where Pig will be installed"
    exit 1
fi

INSTALL_DIR=$1
USER_NAME=`whoami`
pig_version=pig-0.14.0
pig_stable_mirror=http://apache.mirrors.hoobly.com/pig/$pig_version/$pig_version.tar.gz

if [ -d "$INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $INSTALL_DIR"
  exit 1
fi

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "Downloading Pig"
curl -O $pig_stable_mirror

echo "Installing Pig"
tar xfvz $pig_version.tar.gz
echo "Done."
