#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <KIBANA_INSTALL_DIR>"
    echo "KIBANA_INSTALL_DIR: Local directory where Kibana will be installed"
    exit 1
fi

INSTALL_DIR=$1
kibana_version=kibana-4.0.2
kibana_stable_mirror_base=https://download.elastic.co/kibana/kibana

if [ -d "$INSTALL_DIR" ]; then
  echo "Please specify a non-existent installation directory: $INSTALL_DIR"
  exit 1
fi

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

uname_string="$(uname)"
machine="x64"
os="linux"
if [[ $uname_string == *"Darwin"* ]]
then
   os="darwin"
fi 

kibana_stable_mirror=$kibana_stable_mirror_base/$kibana_version-$os-$machine.tar.gz

echo "Downloading Kibana"
curl -O $kibana_stable_mirror

echo "Installing Kibana"
tar xfvz $kibana_version-$os-$machine.tar.gz
mv $kibana_version-$os-$machine $kibana_version
echo "Done."
