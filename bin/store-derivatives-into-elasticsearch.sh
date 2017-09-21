#!/usr/bin/env bash
set -e

if [ $# != 1 ] ; then
    echo "usage: $0 <DERIVATIVES_HOME_DIR>"
    echo "DERIVATIVES_HOME_DIR: directory where derivatives are stored"
    exit 1
fi

DERIVATIVES_HOME_DIR=$1

BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../

cd ${BASE_DIR}

#index CDX data
pig -x local -l /tmp/ -p I_CDX_DIR=${DERIVATIVES_HOME_DIR}/cdx/*cdx* -p O_ES_INDEX_DIR=ars-cdx/cdx pig/store-cdx-data-into-elasticsearch.pig

#index WAT data
pig -x local -l /tmp/ -p I_WAT_DIR=${DERIVATIVES_HOME_DIR}/wat/*.wat.gz -p O_ES_INDEX_DIR=ars-wat-text/text pig/store-wat-text-data-into-elasticsearch.pig

#index WANE data
#create an index mapping for the WANE data (to use keyword analyzer) -- commenting out for now
#curl -XPOST http://localhost:9200/ars-wane -d @ars-es-mappings/ars-wane-mapping.json
pig -x local -l /tmp/ -p I_WANE_DIR=${DERIVATIVES_HOME_DIR}/wane/ -p O_ES_INDEX_DIR=ars-wane/entities pig/store-wane-data-into-elasticsearch.pig
