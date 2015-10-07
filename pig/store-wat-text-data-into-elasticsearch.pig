/* Input: WAT files generated from WARC files
 * Output: WAT text data stored in ES
 */

%default I_WAT_DIR '/Users/archive/Desktop/ars-workshop-data/*wat.gz';
%default O_ES_INDEX_DIR 'ars-wat/text';
%default LIB_DIR 'lib/';
REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER '$LIB_DIR/elasticsearch-hadoop-2.0.2.jar';
SET pig.splitCombination 'false';
SET mapred.max.map.failures.percent 10;
REGISTER lib/ia-porky-jar-with-dependencies.jar;

-- load data from I_WAT_DIR:
Orig = LOAD '$I_WAT_DIR' USING org.archive.hadoop.ArchiveJSONViewLoader('Envelope.WARC-Header-Metadata.WARC-Target-URI',
									 'Envelope.WARC-Header-Metadata.WARC-Date',
									 'Envelope.Payload-Metadata.HTTP-Response-Metadata.Response-Message.Status',
									 'Envelope.Payload-Metadata.HTTP-Response-Metadata.HTML-Metadata.Head.Title',
									 'Envelope.Payload-Metadata.HTTP-Response-Metadata.HTML-Metadata.Head.@Metas.{content,name}')
									 AS (src:chararray,timestamp:chararray,status:chararray,title:chararray,metacontent:chararray, metaname:chararray);

-- get meta text only from HTTP 200 response pages
Orig = FILTER Orig by status == '200';
Orig = FOREACH Orig GENERATE src as url, 
                             timestamp,
                             title,
                             LOWER(metaname) as metaname,
                             metacontent;
Orig = FILTER Orig BY title != '' OR ( metacontent != '' AND (metaname == 'keywords' OR metaname == 'description'));
Orig = FOREACH Orig GENERATE url,
                             timestamp,
                             title,
                             metacontent as metatext;
Lines = GROUP Orig BY (url, timestamp, title);
Lines = FOREACH Lines GENERATE FLATTEN(group) as (url, timestamp, title),
                                                 derivativeUtils.collectBagElements(Orig.metatext,'. ') as metatext;
STORE Lines INTO '$O_ES_INDEX_DIR' USING org.elasticsearch.hadoop.pig.EsStorage();
