#!/usr/bin/env bash
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../

if [ $# -lt 1 ]; then
    echo "$0 <local_data_directory>"
    exit 1
fi

data_dir=$1

docker run --rm -i -t -p 9200:9200 -p 5601:5601 -p 8888:8888 \
       -v ${BASE_DIR}:/ars-workshop -v ${data_dir}:/ars-data \
       -v ${data_dir}/elasticsearch-index-data:/ars-elasticsearch-index-data \
       vinaygoel/ars-docker-notebooks
