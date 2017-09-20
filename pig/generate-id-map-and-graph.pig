/* Input: Parsed Text Captures generated from the 'internetarchive/waimea' project
 * Output: LGA dataset 
 */

%default I_PARSED_DATA_DIR '';
%default I_CDX_DATA_DIR '';
%default O_GRAPH_DATA_DIR '';

%default LIB_DIR 'lib/';
SET mapred.max.map.failures.percent 10;
SET mapred.reduce.slowstart.completed.maps 0.9

REGISTER lib/ia-porky-jar-with-dependencies.jar;
REGISTER lib/datafu-0.0.10.jar;
DEFINE MD5 datafu.pig.hash.MD5();

REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;

SET mapreduce.job.queuename ait;
SET pig.splitCombination 'false';

DEFINE SURTURL org.archive.porky.SurtUrlKey();
DEFINE COMPRESSWHITESPACES org.archive.porky.CompressWhiteSpacesUDF();

DEFINE FROMJSON org.archive.porky.FromJSON();
DEFINE SequenceFileLoader org.archive.porky.SequenceFileLoader();

-- Load the metadata from the parsed data, which is JSON strings stored in a Hadoop SequenceFile.
--Meta  = LOAD '$I_PARSED_DATA_DIR' USING SequenceFileLoader() AS (key:chararray, value:chararray);

--non seq file 
Meta  = LOAD '$I_PARSED_DATA_DIR'  AS (key:chararray, value:chararray);

-- Convert the JSON strings into Pig Map objects.
Meta = FOREACH Meta GENERATE FROMJSON(value) AS m:[];

-- Only retain records where the errorMessage is not present.  Records
-- that failed to parse will be present in the input, but will have an
-- errorMessage property, so if it exists, skip the record.
Meta = FILTER Meta BY m#'errorMessage' is null;

-- Only retain the fields of interest.
Meta = FOREACH Meta GENERATE m#'url'          AS src:chararray,
			     m#'date'         AS timestamp:chararray,
			     m#'code'         AS code:chararray,
                             m#'outlinks'     AS links:{tuple(link:[])};

-- Only extract content from HTTP-200 responses
Meta = FILTER Meta BY code == '200';

Links = FOREACH Meta { 
         LinkData = FOREACH links GENERATE link#'url' AS dst:chararray, link#'text' AS linktext:chararray;
         LinkData = FILTER LinkData BY dst != '';
         LinkData = DISTINCT LinkData;
         GENERATE src, timestamp, FLATTEN(LinkData) as (dst, linktext);
       }

-- canonicalize to SURT form

--Retain original URL?

Links = FOREACH Links GENERATE SURTURL(src) as src, 
			       --ToDate(timestamp,'yyyyMMddHHmmss') as timestamp, 
			       timestamp, 
			       SURTURL(dst) as dst, REPLACE(src,'\n','') as origSrc, REPLACE(dst,'\n','') as origDst;

SurtOrigMap1 = FOREACH Links GENERATE src as url, origSrc as origUrl;
SurtOrigMap2 = FOREACH Links GENERATE dst as url, origDst as origUrl;
SurtOrigMap3 = UNION SurtOrigMap1, SurtOrigMap2;

SurtOrigMapGrp = GROUP SurtOrigMap3 BY url;
SurtOrigMap = FOREACH SurtOrigMapGrp {
			Origs = ORDER SurtOrigMap3 BY origUrl;
			Origs = LIMIT Origs 1;
			GENERATE group as url, FLATTEN(Origs.origUrl) as origUrl;
		};

Links = FOREACH Links GENERATE src, timestamp, dst;
Links = FILTER Links by src is not null and dst is not null;
Links = FILTER Links by src != '' and dst != '';

-- remove self links
Links = FILTER Links by src!=dst;
Links = DISTINCT Links;

S = FOREACH Links GENERATE src as url;
D = FOREACH Links GENERATE dst as url;
A = UNION S, D;
A = DISTINCT A;

-- assign integer identifiers to sorted URLs (SURT sorted allows for pages belonging to the same host having "closer" IDs)
IDMap = RANK A by url;

IDMap = FOREACH IDMap GENERATE $0 as id:chararray, $1 as url:chararray;

--Store this version
IDMapToStore = Join IDMap BY url, SurtOrigMap by url;
IDMapToStore = FOREACH IDMapToStore GENERATE IDMap::id as id, IDMap::url as url, SurtOrigMap::origUrl as origUrl;

-- id relation
IDR = FOREACH IDMap GENERATE url as key, 'm' as type, id as value;
IDR = DISTINCT IDR;

Links = FOREACH Links GENERATE src, timestamp, (chararray)CONCAT(src,timestamp) as srcTs, dst;
Links = FILTER Links BY srcTs is not null;

Links = FOREACH Links GENERATE src, timestamp, MD5(srcTs) as capid, dst;

-- time relation
TR = FOREACH Links GENERATE timestamp as key, 't' as type, capid as value;
TR = DISTINCT TR;

-- sources relation
SR = FOREACH Links GENERATE src as key, 's' as type, capid as value;
SR = DISTINCT SR;

-- destinations relation
DR = FOREACH Links GENERATE dst as key, 'd' as type, capid as value;
DR = DISTINCT DR;

IDSR = UNION IDR, SR;
IDSDR = UNION IDSR, DR;
IDSDR = DISTINCT IDSDR;

-- Resolve IDs
L1 = GROUP IDSDR by key;
L2 = FOREACH L1 {
		
		IDLine = FILTER IDSDR by type == 'm';
		GENERATE FLATTEN(IDLine.value) as newkey, FLATTEN(IDSDR) as (key,type,value);
	};

-- 'm' type no longer needed
L2 = FILTER L2 by type != 'm';
L2 = FOREACH L2 GENERATE newkey as key, type, value;
 
-- now combine L2 with TR
L3 = UNION L2, TR;

-- group by value / capid
-- use Capid to resolve

M1 = GROUP L3 by value;

M2 = FOREACH M1 {
		SLine = FILTER L3 by type == 's'; 
		TLine = FILTER L3 by type == 't';
		GENERATE FLATTEN(SLine.key) as srcid, FLATTEN(TLine.key) as timestamp, FLATTEN(L3) as (key,type,value);
	};

--only need destination type lines
M2 = FILTER M2 by type == 'd';

IDLinks = FOREACH M2 GENERATE srcid, timestamp, key as destid;

--group by source and timestamp
IDLinks2 = GROUP IDLinks by (srcid,timestamp);
IDGraph = FOREACH IDLinks2 {
		dests = DISTINCT IDLinks;
		GENERATE FLATTEN(group) as (id,ts), dests.destid as links;
	};

--Load CDX lines (space separated)
CDXLines = LOAD '$I_CDX_DATA_DIR' USING PigStorage(' ') AS (url:chararray,
                                                       timestamp:chararray,
                                                       orig_url:chararray,
                                                       mime:chararray,
                                                       rescode:chararray,
                                                       checksum:chararray);

--only consider 200 response codes / empty response code in the case of revisits
CDXLines = FILTER CDXLines BY rescode == '200' OR rescode == '-';

UrlTsChecksum = FOREACH CDXLines GENERATE SURTURL(orig_url) as url, timestamp as ts, checksum as checksum;
UrlTsChecksum = DISTINCT UrlTsChecksum;

Joined = Join IDMap BY url, UrlTsChecksum BY url;
IdTsChecksum = FOREACH Joined GENERATE IDMap::id as id, UrlTsChecksum::ts as ts, UrlTsChecksum::checksum as checksum;

Joined = Join IDGraph BY (id,ts), IdTsChecksum BY (id,ts);
IdChecksumLinks = FOREACH Joined GENERATE IdTsChecksum::id as id, IdTsChecksum::checksum as checksum, IDGraph::links as links;
IdChecksumLinks = DISTINCT IdChecksumLinks;

Joined = Join IdTsChecksum BY (id,checksum), IdChecksumLinks BY (id,checksum);
ExpandedIDGraph = FOREACH Joined GENERATE IdTsChecksum::id as id, IdTsChecksum::ts as ts, IdChecksumLinks::links as links;
ExpandedIDGraph = DISTINCT ExpandedIDGraph;

IDMapToStore = FOREACH IDMapToStore GENERATE derivativeUtils.LgaIdMapWriter(id, origUrl, url);
ExpandedIDGraph = FOREACH ExpandedIDGraph GENERATE derivativeUtils.LgaIdGraphWriter(id, ts, links);

STORE IDMapToStore into '$O_GRAPH_DATA_DIR/id.map.gz';
STORE ExpandedIDGraph into '$O_GRAPH_DATA_DIR/id.graph.gz';

