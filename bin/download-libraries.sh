#!/usr/bin/env bash
set -e

BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LIB_DIR=$BIN_DIR/../lib/
CACHE_DIR=$BIN_DIR/../cache/
mkdir -p $LIB_DIR
mkdir -p $CACHE_DIR

downloadPath="https://archive.org/~vinay/archive-analysis/ia-libraries/hadoop-2.x/"
libraryNames=(
       'webarchive-commons-jar-with-dependencies.jar'
       'ia-hadoop-tools-jar-with-dependencies.jar'
       'ia-porky-jar-with-dependencies.jar'
       'english.all.3class.distsim.crf.ser.gz'
       'elephant-bird-hadoop-compat-4.1.jar'
       'elephant-bird-pig-4.1.jar'
       'elasticsearch-hadoop-2.0.2.jar'
       'json-simple-1.1.1.jar'
       'datafu-0.0.10.jar'
       'piggybank.jar'
       'tutorial.jar'
       'jbs.jar'
)       

cd $LIB_DIR

#download
for jar in ${libraryNames[@]}; do
   curl -O $downloadPath/$jar
   if [ $? -ne 0 ]; then
      echo "Unable to download from $downloadPath/$jar"
      exit 1
   fi
done

cacheFileNames=(
       'GeoLiteCity.dat'
       'geo-pack.tgz'
       'stop-words.txt'
)       

cd $CACHE_DIR

#download
for cacheFile in ${cacheFileNames[@]}; do
   curl -O $downloadPath/$cacheFile
   if [ $? -ne 0 ]; then
      echo "Unable to download from $downloadPath/$cacheFile"
      exit 1
   fi
done

echo "==========================================================="
echo "Libraries downloaded to $LIB_DIR and $CACHE_DIR"
echo "==========================================================="
