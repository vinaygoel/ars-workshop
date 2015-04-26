#!/usr/bin/env bash
set -e

BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

LIB_DIR=$BIN_DIR/../lib/

mkdir -p $LIB_DIR

downloadPath="https://archive.org/~vinay/archive-analysis/ia-libraries/hadoop-2.x/"

fatJarNames=(
       'webarchive-commons-jar-with-dependencies.jar'
       'ia-hadoop-tools-jar-with-dependencies.jar'
       'ia-porky-jar-with-dependencies.jar'
       'english.all.3class.distsim.crf.ser.gz'
       'elephant-bird-hadoop-compat-4.1.jar'
       'elephant-bird-pig-4.1.jar'
       'json-simple-1.1.1.jar'
       'datafu-0.0.10.jar'
       'piggybank.jar'
       'tutorial.jar'
       'jbs.jar'
)       

cd $LIB_DIR

#download
for jar in ${fatJarNames[@]}; do
   curl -O $downloadPath/$jar
   if [ $? -ne 0 ]; then
      echo "Unable to download JAR from $downloadPath/$jar"
      exit 1
   fi
done

echo "==========================================================="
echo "Fat JARs downloaded to $LIB_DIR"
echo "==========================================================="

