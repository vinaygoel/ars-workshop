/* Input: WAT files generated from WARC files
 * Output: CSV file (date, latitude, longitude)
 */

%default I_WAT_DIR '/Users/archive/Desktop/ars-workshop-data/*wat.gz';
%default O_DATE_LAT_LONG_COUNT_DIR '/tmp/date-lat-long-count/';

%default LIB_DIR 'lib/';
%default CACHE_DIR 'cache/';

SET mapred.cache.files '$CACHE_DIR/geo-pack.tgz';
SET pig.splitCombination 'false';
SET mapred.max.map.failures.percent 10;

DEFINE iplookup `ipwrapper.sh` SHIP ('$CACHE_DIR/ipwrapper.sh') cache('$CACHE_DIR/GeoLiteCity.dat#GeoLiteCity.dat');

REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER '$LIB_DIR/elasticsearch-hadoop-2.0.2.jar';
REGISTER lib/ia-porky-jar-with-dependencies.jar;
DEFINE EXTRACTYEARFROMDATE org.archive.porky.ExtractYearFromDate();

IP = LOAD '$I_WAT_DIR' USING org.archive.hadoop.ArchiveJSONViewLoader(
                             'Envelope.WARC-Header-Metadata.WARC-Date',
                             'Envelope.WARC-Header-Metadata.WARC-IP-Address'
                             ) AS (timestamp:chararray, ip:chararray);

IP = FOREACH IP GENERATE derivativeUtils.getDateFormatFromWARCTS(timestamp) as crawlDate, ip;
IP = FILTER IP BY crawlDate is not null AND ip is not null AND ip != '';
IPGrp = GROUP IP BY (crawlDate,ip);
Result = FOREACH IPGrp GENERATE FLATTEN(group) as (crawlDate,ip), COUNT(IP) as count;

Lines = STREAM Result THROUGH iplookup AS (yearMonth:chararray, latlong:chararray, count:long);
LinesGrp = GROUP Lines BY (yearMonth,latlong);
Result = FOREACH LinesGrp GENERATE FLATTEN(group) as (yearMonth,latlong), SUM(Lines.count) as count;
STORE Result into '$O_DATE_LAT_LONG_COUNT_DIR';
