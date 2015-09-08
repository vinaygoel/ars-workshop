/* Input: WANE files 
 * Output: Entity data stored in ES index
 */

%default I_WANE_DIR '/Users/archive/Desktop/ars-workshop-data/*wane.gz';
%default O_ES_INDEX_DIR 'ars-wane/entities';
%default LIB_DIR 'lib/';

REGISTER '$LIB_DIR/elasticsearch-hadoop-2.0.2.jar';
SET pig.noSplitCombination TRUE;

REGISTER '$LIB_DIR/elephant-bird-hadoop-compat-4.1.jar';
REGISTER '$LIB_DIR/elephant-bird-pig-4.1.jar';
REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;

DEFINE FROMJSON com.twitter.elephantbird.pig.piggybank.JsonStringToMap();

-- Load WANE data
Lines = LOAD '$I_WANE_DIR' as (value: chararray);
Lines = FOREACH Lines GENERATE FROMJSON(value) AS m:[];
Lines = FOREACH Lines GENERATE m#'url'             AS url:chararray,
                               m#'timestamp'       AS timestamp:chararray,
                               m#'digest'          AS digest:chararray,
                               m#'named_entities'  AS entityString:chararray;

Lines = FOREACH Lines GENERATE url, 
                               timestamp,
                               digest,
                               FROMJSON(entityString) AS m:[];

Lines = FOREACH Lines GENERATE url,
                               ToDate(timestamp,'yyyyMMddHHmmss') as timestamp,
                               digest,
                               derivativeUtils.generateBagFromArray(m#'PERSON') as persons,
                               derivativeUtils.generateBagFromArray(m#'ORGANIZATION') as organizations,
                               derivativeUtils.generateBagFromArray(m#'LOCATION') as locations;

STORE Lines INTO '$O_ES_INDEX_DIR' USING org.elasticsearch.hadoop.pig.EsStorage();
