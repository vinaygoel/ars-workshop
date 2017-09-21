#!/usr/bin/env bash
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../

parsed_dir=$1
wane_dir=$2

CLASSIFIER=english.all.3class.distsim.crf.ser.gz
CLASSIFIER_PATH=${BASE_DIR}/lib/${CLASSIFIER}

pig -Dmapred.cache.files="${CLASSIFIER_PATH}#${CLASSIFIER}" -Dmapred.create.symlink=yes -x local -l /tmp/ -p I_NER_CLASSIFIER_FILE=${CLASSIFIER} -p I_PARSED_DATA_DIR=${parsed_dir} -p O_ENTITIES_DIR=${wane_dir} $BASE_DIR/pig/extract-entities.pig

