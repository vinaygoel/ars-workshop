/* Input: WAT files generated from WARC files
 * Output: Linked videos along with number of inlinks and top "anchor text" terms stored in ES 
 */

%default I_WAT_DIR '/tmp/ars-exercises-derivatives/wat/FERGYTV-20150207124415-00415_warc.wat.gz';
%default O_ES_INDEX_DIR 'ars-wat-videos/videos';
%default I_VIDEO_URL_FILTER '.*youtube.com/watch.*';

%default LIB_DIR 'lib/';
%default CACHE_DIR 'cache/';
%default I_STOP_WORDS_FILE 'stop-words.txt';

REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER '$LIB_DIR/tutorial.jar';
REGISTER '$LIB_DIR/piggybank.jar';
REGISTER '$LIB_DIR/ia-porky-jar-with-dependencies.jar';
REGISTER '$LIB_DIR/elasticsearch-hadoop-2.0.2.jar';

SET pig.splitCombination 'false';
SET mapred.max.map.failures.percent 10;
SET mapred.create.symlink yes;
SET mapred.cache.files '$CACHE_DIR/stop-words.txt#stop-words.txt';

DEFINE TOKENIZETEXT org.archive.porky.TokenizeTextUDF('$I_STOP_WORDS_FILE');
DEFINE TOLOWER org.apache.pig.tutorial.ToLower();
DEFINE URLRESOLVE org.archive.hadoop.func.URLResolverFunc();
DEFINE SURTURL org.archive.porky.SurtUrlKey();
DEFINE COMPRESSWHITESPACES org.archive.porky.CompressWhiteSpacesUDF();
DEFINE TOLOWER org.apache.pig.tutorial.ToLower();

-- load data from I_WAT_DIR:
Orig = LOAD '$I_WAT_DIR' USING
          org.archive.hadoop.ArchiveJSONViewLoader(
          'Envelope.WARC-Header-Metadata.WARC-Target-URI',
          'Envelope.WARC-Header-Metadata.WARC-Date',
	  'Envelope.Payload-Metadata.HTTP-Response-Metadata.HTML-Metadata.Head.Base',
	  'Envelope.Payload-Metadata.HTTP-Response-Metadata.HTML-Metadata.@Links.{url,path,text,alt}'
          ) as (src:chararray,
                timestamp:chararray,
                html_base:chararray,
                relative:chararray,
                path:chararray,
                text:chararray,
                alt:chararray);

-- discard lines without links
LinksOnly = FILTER Orig by relative != '';

-- Generate the resolved destination-URL
Links = FOREACH LinksOnly GENERATE src, 
                                   timestamp,
                                   URLRESOLVE(src,html_base,relative)
                                   as dst, path, CONCAT(text,alt) as linktext;

Destinations = FOREACH Links GENERATE SURTURL(dst) as url,
                                      dst as orig_url,
                                      path,
                                      COMPRESSWHITESPACES(linktext) as linktext;

Destinations = FILTER Destinations BY url is not null and url != '';

--Example to extract Images with alt text
--ImageEmbeds = FILTER Destinations BY path == 'IMG@/src' AND linktext is not null AND linktext != '';
--ImageEmbeds = FOREACH ImageEmbeds GENERATE url, orig_url, linktext;

Links = FILTER Destinations BY path == 'A@/href' AND linktext is not null AND linktext != '';
Links = FOREACH Links GENERATE url, orig_url, linktext;

--only find links to urls matching the pattern
VideoLinks = FILTER Links BY TOLOWER(orig_url) matches '$I_VIDEO_URL_FILTER';

VideoLinksGrp = GROUP VideoLinks BY url;
Data = FOREACH VideoLinksGrp {
                  OrigUrls = ORDER VideoLinks BY orig_url;
                  OrigUrls = LIMIT OrigUrls 1;
                  GENERATE FLATTEN(OrigUrls.orig_url) as url,
                           derivativeUtils.collectBagElements(VideoLinks.linktext,' ') as linktext,
                           COUNT(VideoLinks) as num_links;
                  };

Data = FOREACH Data GENERATE url,
                             num_links,
                             FLATTEN(TOKENIZE(TOKENIZETEXT(TOLOWER(linktext)))) as term;

/* -- To index only top anchor terms per URL 
DocsGrp = GROUP Data BY (url, num_links, term);
DocsGrp2 = FOREACH DocsGrp GENERATE FLATTEN(group) as (url, num_links, term), COUNT(Data) as term_freq;
TopTermFreqScores = GROUP DocsGrp2 BY (url, num_links);
Out = FOREACH TopTermFreqScores {
                sorted = ORDER DocsGrp2 BY term_freq DESC;
                topN = LIMIT sorted 20;
                GENERATE FLATTEN(group) as (url, num_links), topN.term as top_term;
        };
STORE Out INTO '$O_ES_INDEX_DIR' USING org.elasticsearch.hadoop.pig.EsStorage();
*/

--Index all unique anchor terms per URL
Data = DISTINCT Data;
DataGrp = GROUP Data BY (url,num_links);
DataGrp = FOREACH DataGrp GENERATE FLATTEN(group) as (url, num_links), Data.term as anchor_term;
STORE DataGrp INTO '$O_ES_INDEX_DIR' USING org.elasticsearch.hadoop.pig.EsStorage();
