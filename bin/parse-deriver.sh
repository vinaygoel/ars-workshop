#!/usr/bin/env bash
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASE_DIR=$BIN_DIR/../
PARSE_HOME=${BASE_DIR}/lib/parse/

HEAP_MAX=4096
TMP_DIR=/tmp/

warc_file=${1}
parse_file=${2}

if timeout 36000 /usr/bin/java \
    -Dproc_jar \
    -Djava.io.tmpdir=${TMP_DIR} \
    -Xmx${HEAP_MAX}m \
    -Dhadoop.log.dir=${PARSE_HOME}/logs \
    -Dhadoop.log.file=hadoop.log \
    -Dhadoop.home.dir=${PARSE_HOME} \
    -Dhadoop.root.logger=ERROR,console \
    -Djava.library.path=${PARSE_HOME}/lib/native/Linux-amd64-64 \
    -classpath ${PARSE_HOME}/conf:/usr/lib/tools.jar:${PARSE_HOME}/lib/hadoop-core-0.20.2-cdh3u3.jar:${PARSE_HOME}/lib/commons-cli-1.2.jar:${PARSE_HOME}/lib/commons-httpclient-3.1.jar:${PARSE_HOME}/lib/commons-logging-1.0.4.jar:${PARSE_HOME}/lib/commons-logging-api-1.0.4.jar:${PARSE_HOME}/lib/guava-r09-jarjar.jar:${PARSE_HOME}/lib/jackson-core-asl-1.5.2.jar:${PARSE_HOME}/lib/jackson-mapper-asl-1.5.2.jar:${PARSE_HOME}/lib/log4j-1.2.15.jar:${PARSE_HOME}/lib/jsp-2.1/*.jar:${PARSE_HOME}/lib/oro-2.0.8.jar \
    org.apache.hadoop.util.RunJar ${PARSE_HOME}/lib/jbs-*.jar org.archive.jbs.Parse \
    -Dnutchwax.parse.pdf2.pdftotext.path=${PARSE_HOME}/bin/pdftotext_timed.sh \
    -conf ${PARSE_HOME}/conf/job-parse.xml \
    ${TMP_DIR} \
    ${warc_file} ;
then
    mv -v ${TMP_DIR}/${warc_file##*/} ${parse_file}
    exit 0
else
    echo "Un-oh!"
    exit 1
fi
