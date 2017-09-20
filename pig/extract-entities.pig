/* Input: Parsed Text Captures generated from the 'internetarchive/waimea' project
 * Output: WANE dataset (URL, digest, date, entities)
 */

--pig -Dmapred.cache.files="/user/vinay/english.all.3class.distsim.crf.ser.gz#english.all.3class.distsim.crf.ser.gz" -Dmapred.create.symlink=yes -p I_NER_CLASSIFIER_FILE=english.all.3class.distsim.crf.ser.gz

%default I_PARSED_DATA_DIR '/search/ait/231/parsed/231-20051006190750-00000-crawling019.arc.gz';
%default O_ENTITIES_DIR '/tmp/ent-8';
%default I_URL_PREFIX_FILTER '^.*$';
%default I_NER_CLASSIFIER_FILE '/tmp/hadoop/cache/english.all.3class.distsim.crf.ser.gz';
%default LIB_DIR 'lib/';

SET pig.splitCombination 'false';
SET mapred.max.map.failures.percent 10;
SET mapred.reduce.slowstart.completed.maps 0.9

REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER lib/ia-porky-jar-with-dependencies.jar;
REGISTER lib/tutorial.jar;
REGISTER lib/json-simple-1.1.1.jar;
REGISTER lib/elephant-bird-hadoop-compat-4.1.jar;
REGISTER lib/elephant-bird-pig-4.1.jar;
REGISTER lib/piggybank.jar;

DEFINE TOLOWER org.apache.pig.tutorial.ToLower();
DEFINE FROMJSON com.twitter.elephantbird.pig.piggybank.JsonStringToMap();
DEFINE SequenceFileLoader org.apache.pig.piggybank.storage.SequenceFileLoader();
DEFINE SequenceFileStorage com.twitter.elephantbird.pig.store.SequenceFileStorage();
DEFINE SURTURL org.archive.porky.SurtUrlKey();
DEFINE NER3CLASS org.archive.porky.NER3ClassUDF('$I_NER_CLASSIFIER_FILE');

-- Load the metadata from the parsed data, which is JSON strings stored in a Hadoop SequenceFile.
--Meta  = LOAD '$I_PARSED_DATA_DIR' USING SequenceFileLoader() AS (key:chararray, value:chararray);

--non seq file input
Meta  = LOAD '$I_PARSED_DATA_DIR' AS (key:chararray, value:chararray);

-- Convert the JSON strings into Pig Map objects.
Meta = FOREACH Meta GENERATE FROMJSON(value) AS m:[];

-- Only retain records where the errorMessage is not present.  Records
-- that failed to parse will be present in the input, but will have an
-- errorMessage property, so if it exists, skip the record.
Meta = FILTER Meta BY m#'errorMessage' is null;

-- Only retain the fields of interest.
Meta = FOREACH Meta GENERATE m#'url'           AS src:chararray,
			     m#'code'          AS code:chararray,
			     m#'date'          AS date:chararray,
			     m#'digest'        AS digest:chararray,
			     m#'content'       AS content:chararray;

-- Only extract content from HTTP-200 responses
Meta = FILTER Meta BY code == '200';

-- canonicalize the URL
Meta = FOREACH Meta GENERATE src, date, digest, content;

--filter out robots.txt captures
Meta = FILTER Meta BY not src matches '.*robots.txt$';

--FILTER by url prefix
Meta = FILTER Meta BY src matches '$I_URL_PREFIX_FILTER';

Entities = FOREACH Meta GENERATE src as url, date, digest, NER3CLASS(content) as entityString;
Wane = FOREACH Entities GENERATE derivativeUtils.WaneWriter(url, date, digest, entityString);
STORE Wane into '$O_ENTITIES_DIR';  

