/* Input: CDX files generated from WARC files
 * Output: CDX lines stored in ES index
 */

%default I_CDX_DIR '';
%default O_ES_INDEX_DIR 'ars-cdx/cdx';
%default LIB_DIR 'lib/';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER '$LIB_DIR/elasticsearch-hadoop-2.0.2.jar';

SET pig.noSplitCombination TRUE;

--Load SURT CDX lines (space separated)
CDX = LOAD '$I_CDX_DIR' USING PigStorage(' ') AS (surt_url:chararray,
                                                  timestamp:chararray,
                                                  orig_url:chararray,
                                                  mime:chararray,
                                                  response_code:chararray,
                                                  content_digest:chararray,
                                                  redirect_url:chararray,
                                                  meta_tags:chararray,
                                                  compressed_size:chararray,
                                                  file_offset:chararray,
                                                  file_name:chararray);
CDX = FILTER CDX BY surt_url != '';
CDX = FOREACH CDX GENERATE surt_url, ToDate(timestamp,'yyyyMMddHHmmss') as timestamp,
                           orig_url, mime, response_code, content_digest, redirect_url,
                           meta_tags, compressed_size, file_offset, file_name;
STORE CDX INTO '$O_ES_INDEX_DIR' USING org.elasticsearch.hadoop.pig.EsStorage();

