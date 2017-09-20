#!/usr/bin/env bash
set -e

BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LIB_DIR=$BIN_DIR/../lib/
CACHE_DIR=$BIN_DIR/../cache/
mkdir -p $LIB_DIR
mkdir -p $CACHE_DIR

source $BIN_DIR/functions.sh

downloadPath="https://archive.org/~vinay/archive-analysis/ia-libraries/hadoop-2.x/"
libraryNames=(
       'webarchive-commons-jar-with-dependencies.jar' #https://github.com/internetarchive/webarchive-commons/tree/hadoop-2
       'ia-hadoop-tools-jar-with-dependencies.jar' #https://github.com/internetarchive/ia-hadoop-tools/tree/hadoop2-prep
       'ia-porky-jar-with-dependencies.jar' #https://github.com/vinaygoel/archive-analysis/tree/master/ia-porky
       'english.all.3class.distsim.crf.ser.gz' #http://nlp.stanford.edu/software/CRF-NER.shtml
       'elephant-bird-hadoop-compat-4.1.jar' #https://github.com/twitter/elephant-bird/
       'elephant-bird-pig-4.1.jar' #https://github.com/twitter/elephant-bird/
       'elasticsearch-hadoop-2.0.2.jar' #https://github.com/elastic/elasticsearch-hadoop
       'json-simple-1.1.1.jar' #https://code.google.com/p/json-simple/
       'datafu-0.0.10.jar' #https://github.com/linkedin/datafu
       'piggybank.jar' #https://cwiki.apache.org/confluence/display/PIG/PiggyBank
       'tutorial.jar' #https://cwiki.apache.org/confluence/display/PIG/PigTutorial
       'jbs.jar' #https://github.com/internetarchive/jbs
       'jyson-1.0.2.zip' #http://opensource.xhaus.com/attachments/download/3/jyson-1.0.2.zip
       'parse.tar.gz' #parse home for parsed text generation
)

cd $LIB_DIR

#download
for jar in ${libraryNames[@]}; do
   downloadFile $downloadPath $jar
done

unzip -o jyson-1.0.2.zip
tar xf parse.tar.gz

cacheFileNames=(
       'GeoLiteCity.dat' #http://dev.maxmind.com/geoip/legacy/geolite/
       'geo-pack.tgz'
       'stop-words.txt'
)

cd $CACHE_DIR

#download
for cacheFile in ${cacheFileNames[@]}; do
   downloadFile $downloadPath $cacheFile
done

echo "==========================================================="
echo "Libraries downloaded to $LIB_DIR and $CACHE_DIR"
echo "==========================================================="
