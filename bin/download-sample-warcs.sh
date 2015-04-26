#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <LOCAL_WARC_DIR>"
    echo "LOCAL_WARC_DIR: Local directory where WARCs will be copied to"
    exit 1
fi

LOCAL_WARC_DIR=$1

downloadPath="https://archive.org/~vinay/archive-analysis/sample-dataset/crawl-data/warcs/"

# WARC files to download
warcNames=(
     'NARA-112TH-CONGRESS-2012-20121211213007728-00000-18872~wbgrp-crawl025.us.archive.org~8443.warc.gz'
   )

mkdir -p $LOCAL_WARC_DIR/warcs/
if [ $? -ne 0 ]; then
  echo "Unable to create temporary directory: $LOCAL_WARC_DIR/warcs/"
  exit 2
fi

cd $LOCAL_WARC_DIR/warcs/

#download
for warc in ${warcNames[@]}; do
   curl -O $downloadPath/$warc
   if [ $? -ne 0 ]; then
      echo "Unable to download WARC from $downloadPath/$warc"
      exit 3
   fi
done

echo "==========================================================="
echo "Sample WARC(s) downloaded to $LOCAL_WARC_DIR/warcs/"
echo "==========================================================="

