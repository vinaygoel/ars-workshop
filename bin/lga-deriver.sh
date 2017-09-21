#!/usr/bin/env bash
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../

cdx_dir=$1
parsed_dir=$2
lga_dir=$3

pig -x local -l /tmp/logs -p I_PARSED_DATA_DIR=${parsed_dir} -p I_CDX_DATA_DIR=${cdx_dir} -p O_GRAPH_DATA_DIR=${lga_dir} $BASE_DIR/pig/generate-id-map-and-graph.pig
