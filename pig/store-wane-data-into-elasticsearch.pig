/* Input: WANE files 
 * Output: Entity data stored in ES index
 */

%default I_WANE_DIR '/Users/archive/Desktop/ars-workshop-data/*wane.gz';
%default O_ES_INDEX_DIR 'ars-wane/entities';
%default LIB_DIR 'lib/';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER '$LIB_DIR/elasticsearch-hadoop-2.0.2.jar';
SET pig.noSplitCombination TRUE;

Lines = LOAD '$I_WANE_DIR' AS (url:chararray,
                               timestamp:chararray,
                               digest:chararray,
                               entityString:chararray);
Lines = FOREACH Lines GENERATE url, 
                               timestamp,
                               digest,
                               derivativeUtils.get_entity_bags(entityString)
                               as entities:tuple(
                                  persons,
                                  organizations,
                                  locations);
Lines = FOREACH Lines GENERATE url,
                               ToDate(timestamp,'yyyyMMddHHmmss') as timestamp,
                               digest,
                               entities.persons as persons,
                               entities.organizations as organizations,
                               entities.locations as locations;
STORE Lines INTO '$O_ES_INDEX_DIR' USING org.elasticsearch.hadoop.pig.EsStorage();

