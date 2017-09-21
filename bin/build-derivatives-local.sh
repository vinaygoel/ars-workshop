#!/usr/bin/env bash
set -e

if [ $# != 2 ] ; then
    echo "usage: $0 <LOCAL_WARC_DIR> <LOCAL_DERIVATIVE_DIR>"
    echo "LOCAL_WARC_DIR: Local directory where WARCs are stored"
    echo "LOCAL_DERIVATIVE_DIR: Local directory where derivatives will be built"
    exit 1
fi

LOCAL_WARC_DIR=$1
LOCAL_DERIVATIVE_DIR=$2

BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../

if [ ! "$(ls $LOCAL_WARC_DIR/*arc.gz)" ]; then
  echo "No WARC files found under LOCAL_WARC_DIR ($LOCAL_WARC_DIR) !!"
  exit 0
fi

mkdir -p $LOCAL_DERIVATIVE_DIR

LOCAL_CDX_DIR=$LOCAL_DERIVATIVE_DIR/cdx/
LOCAL_WAT_DIR=$LOCAL_DERIVATIVE_DIR/wat/
LOCAL_PARSED_DIR=$LOCAL_DERIVATIVE_DIR/parsed/
LOCAL_WANE_DIR=$LOCAL_DERIVATIVE_DIR/wane/
LOCAL_LGA_DIR=$LOCAL_DERIVATIVE_DIR/lga/

cd ${BASE_DIR}

echo "Building derivatives..."

echo "1) CDX..."

mkdir -p ${LOCAL_CDX_DIR}

for warc_file in $LOCAL_WARC_DIR/*arc.gz; do
	cdx_file=$(basename $warc_file)
	cdx_file=${cdx_file%%.gz}.cdx.gz
	bin/cdx-deriver.sh ${warc_file} ${LOCAL_CDX_DIR}/${cdx_file}
done

echo "2) Parsed Text..."

mkdir -p ${LOCAL_PARSED_DIR}
for warc_file in $LOCAL_WARC_DIR/*arc.gz; do 
	parsed_file=$(basename $warc_file)
	parsed_file=${parsed_file%%.gz}.parsed.gz
	bin/parse-deriver.sh ${warc_file} ${LOCAL_PARSED_DIR}/${parsed_file}
done

echo "3) WAT..."

mkdir -p ${LOCAL_WAT_DIR}
for warc_file in $LOCAL_WARC_DIR/*arc.gz; do 
	wat_file=$(basename $warc_file)
	wat_file=${wat_file%%.gz}.wat.gz
	bin/wat-deriver.sh ${warc_file} ${LOCAL_WAT_DIR}/${wat_file}
done

echo "4) WANE..."

rm -rf ${LOCAL_WANE_DIR} > /dev/null
bin/wane-deriver.sh ${LOCAL_PARSED_DIR} ${LOCAL_WANE_DIR}

echo "5) LGA..."

rm -rf ${LOCAL_LGA_DIR} > /dev/null
bin/lga-deriver.sh ${LOCAL_CDX_DIR} ${LOCAL_PARSED_DIR} ${LOCAL_LGA_DIR}

echo "Done!"
