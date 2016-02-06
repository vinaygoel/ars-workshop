#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <ARS_DERIVATIVES_DIR>"
    echo "ARS_DERIVATIVES_DIR: Local directory where derivatives for the workshop will be copied to"
    exit 1
fi

BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ARS_DERIVATIVES_DIR=$1

source $BIN_DIR/functions.sh

downloadPath="https://archive.org/~vinay/archive-analysis/datasets/"

# derivative datasets to download
derivative_names=(
     'cdx-ferguson-youtube-crawl.tar.gz'
     'lga-ferguson-youtube-crawl-v2.tar.gz'
     'wane-ferguson-youtube-crawl-v2.tar.gz'
     'wat-ferguson-youtube-crawl.tar.gz'
     'wat-sample-charlie-hebdo-crawl.tar.gz'
     'wat-sample-occupy-crawl.tar.gz'
   )

mkdir -p $ARS_DERIVATIVES_DIR/
if [ $? -ne 0 ]; then
  echo "Unable to create temporary directory: $ARS_DERIVATIVES_DIR/"
  exit 2
fi

cd $ARS_DERIVATIVES_DIR/

#download and unpack
for derivative_tar_ball in ${derivative_names[@]}; do
   downloadFile $downloadPath $derivative_tar_ball
   tar xfz $derivative_tar_ball
done

echo "==========================================================="
echo "Workshop derivatives available under $ARS_DERIVATIVES_DIR/"
echo "==========================================================="
