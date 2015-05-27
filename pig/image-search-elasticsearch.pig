/* Input: WAT files generated from WARC files
 * Output: Embedded images along with number of inlinks and top "alt text" terms stored in ES 
 */

%default I_WAT_DIR '';
%default O_ES_INDEX_DIR 'ars-wat-images/images';

%default LIB_DIR 'lib/';
%default CACHE_DIR 'cache/';
%default I_STOP_WORDS_FILE 'stop-words.txt';

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

--Images with alt text
ImageEmbeds = FILTER Destinations BY path == 'IMG@/src' AND linktext is not null AND linktext != '';
ImageEmbeds = FOREACH ImageEmbeds GENERATE url, orig_url, linktext;

ImageEmbedsGrp = GROUP ImageEmbeds BY url;
ImageData = FOREACH ImageEmbedsGrp {
                  OrigUrls = ORDER ImageEmbeds BY orig_url;
                  OrigUrls = LIMIT OrigUrls 1;
                  GENERATE FLATTEN(OrigUrls.orig_url) as url,
                           derivativeUtils.collectBagElements(ImageEmbeds.linktext,' ') as linktext,
                           COUNT(ImageEmbeds) as num_links;
                  };

ImageData = FOREACH ImageData GENERATE url,
                                       num_links,
                                       FLATTEN(TOKENIZE(TOKENIZETEXT(TOLOWER(linktext)))) as term;

DocsGrp = GROUP ImageData BY (url, num_links, term);
DocsGrp2 = FOREACH DocsGrp GENERATE FLATTEN(group) as (url, num_links, term), COUNT(ImageData) as term_freq;
TopTermFreqScores = GROUP DocsGrp2 BY (url, num_links);
Out = FOREACH TopTermFreqScores {
                sorted = ORDER DocsGrp2 BY term_freq DESC;
                topN = LIMIT sorted 20;
                GENERATE FLATTEN(group) as (url, num_links), topN.term as top_term;
        };
STORE Out INTO '$O_ES_INDEX_DIR' USING org.elasticsearch.hadoop.pig.EsStorage();
