/* Input: LGA Dataset
 * Output:  Generate the in-degree (number of incoming links) and out-degree (number of outgoing links) for each URL
 *          Generate the distribution of in-degree and out-degree (i.e. how many URLs share the same degree value)
 */

%default I_LGA_DIR '';
%default I_DATE_FILTER '^201.*$';
%default O_DEGREE_DISTRIBUTION_DIR '';

%default LIB_DIR 'lib/';
REGISTER '$LIB_DIR/elephant-bird-hadoop-compat-4.1.jar';
REGISTER '$LIB_DIR/elephant-bird-pig-4.1.jar';
DEFINE FROMJSON com.twitter.elephantbird.pig.piggybank.JsonStringToMap();
REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;

-- Load LGA data
Graph = LOAD '$I_LGA_DIR/id.graph.gz/' as (value: chararray);
Graph = FOREACH Graph GENERATE FROMJSON(value) AS m:[];
Graph = FOREACH Graph GENERATE m#'id'           AS src:chararray,
                               m#'timestamp'    AS timestamp:chararray,
                               m#'outlink_ids'  AS outlink_ids_array:chararray;
Graph = FOREACH Graph GENERATE src, timestamp, derivativeUtils.generateBagFromArray(outlink_ids_array) as dests:{d:(dst:chararray)};

IdMap = LOAD '$I_LGA_DIR/id.map.gz/' as (value: chararray);
IdMap = FOREACH IdMap GENERATE FROMJSON(value) AS m:[];
IdMap = FOREACH IdMap GENERATE m#'id'           AS id:chararray,
                               m#'url'          AS orig_url:chararray,
                               m#'surt_url'     AS surt_url:chararray;

--filter out timestamps as needed.
Graph = FILTER Graph BY timestamp matches '$I_DATE_FILTER';

-- then, produce link data
Links = FOREACH Graph GENERATE src, FLATTEN(dests) as dst;
Links = DISTINCT Links;

Out = GROUP Links by src;
Out = FOREACH Out {
		GENERATE group as id, COUNT(Links) as numOutLinks:long;
	};

In = GROUP Links by dst;
In = FOREACH In {
		GENERATE group as id, COUNT(Links) as numInLinks:long;
	};

IdMap = FOREACH IdMap GENERATE id, orig_url;
IdMapWithIn = Join IdMap BY id left, In BY id;
IdMapWithIn = FOREACH IdMapWithIn GENERATE IdMap::id as id, IdMap::orig_url as orig_url, (In::numInLinks is null ? 0 : In::numInLinks) as indegree;

IdInOut = Join IdMapWithIn BY id left, Out BY id;
IdInOut = FOREACH IdInOut GENERATE IdMapWithIn::id as id, IdMapWithIn::orig_url as orig_url, IdMapWithIn::indegree as indegree, (Out::numOutLinks is null ? 0 : Out::numOutLinks) as outdegree;
IdInOut = FOREACH IdInOut GENERATE orig_url, indegree, outdegree;
IdInOut = ORDER IdInOut BY indegree DESC;
STORE IdInOut into '$O_DEGREE_DISTRIBUTION_DIR/url-indegree-outdegree/';

OutDegreeDistribution = GROUP Out by numOutLinks;
OutDegreeDistribution = FOREACH OutDegreeDistribution GENERATE group as numOutLinks, COUNT(Out) as numnodes;
OutDegreeDistribution = ORDER OutDegreeDistribution BY numnodes DESC;

InDegreeDistribution = GROUP In by numInLinks;
InDegreeDistribution = FOREACH InDegreeDistribution GENERATE group as numInLinks, COUNT(In) as numnodes;
InDegreeDistribution = ORDER InDegreeDistribution BY numnodes DESC;

STORE OutDegreeDistribution into '$O_DEGREE_DISTRIBUTION_DIR/outdegree-numurls/';
STORE InDegreeDistribution into '$O_DEGREE_DISTRIBUTION_DIR/indegree-numurls/';
