#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <ELASTICSEARCH_INSTALL_DIR>"
    echo "ELASTICSEARCH_INSTALL_DIR: Local directory where Elasticsearch will be installed"
    exit 1
fi

INSTALL_DIR=$1
USER_NAME=`whoami`
elasticsearch_version=elasticsearch-1.5.2
elasticsearch_stable_mirror=https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.2.tar.gz

if [ -d "$INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $INSTALL_DIR"
  exit 1
fi

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "Downloading Elasticsearch"
curl -O $elasticsearch_stable_mirror

echo "Installing Elasticsearch"
tar xfvz $elasticsearch_version.tar.gz
echo "Done."
