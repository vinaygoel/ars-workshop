#!/usr/bin/env bash
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../

warc_file=$1
cdx_file=$2

java -jar $BASE_DIR/lib/ia-hadoop-tools-jar-with-dependencies.jar extractor -cdx ${warc_file} | gzip > ${cdx_file}

