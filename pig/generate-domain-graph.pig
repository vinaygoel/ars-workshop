/* Input: LGA Dataset
 * Output:  Generate a domain graph dataset that contains the following tab-separated fields: source_domain, destination_domain and num_links, where num_links is the number of links from pages of the source_domain to pages in the destination_domain.
 */

%default I_LGA_DIR '';
%default I_DATE_FILTER '^201.*$';
%default O_DOMAIN_GRAPH_DIR '';
%default LIB_DIR 'lib/';
REGISTER '$LIB_DIR/jyson-1.0.2/lib/jyson-1.0.2.jar';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER '$LIB_DIR/elephant-bird-hadoop-compat-4.1.jar';
REGISTER '$LIB_DIR/elephant-bird-pig-4.1.jar';
DEFINE FROMJSON com.twitter.elephantbird.pig.piggybank.JsonStringToMap();
REGISTER lib/ia-porky-jar-with-dependencies.jar;
DEFINE DOMAIN org.archive.porky.ExtractTopPrivateDomainFromHostNameUDF();

-- Load LGA data
Graph = LOAD '$I_LGA_DIR/id.graph.gz/' as (value: chararray);
Graph = FOREACH Graph GENERATE FROMJSON(value) AS m:[];
Graph = FOREACH Graph GENERATE m#'id'           AS src:chararray,
                               m#'timestamp'    AS timestamp:chararray,
                               m#'outlink_ids'  AS outlink_ids_array:chararray;
Graph = FOREACH Graph GENERATE src, timestamp, derivativeUtils.generateBagFromArray(outlink_ids_array) as dests:{dest:(dst:chararray)};

IdMap = LOAD '$I_LGA_DIR/id.map.gz/' as (value: chararray);
IdMap = FOREACH IdMap GENERATE FROMJSON(value) AS m:[];
IdMap = FOREACH IdMap GENERATE m#'id'           AS id:chararray,
                               m#'url'          AS orig_url:chararray,
                               m#'surt_url'     AS surt_url:chararray;

HostIdMap = FOREACH IdMap GENERATE derivativeUtils.getHostFromSurtUrl(surt_url) as host, id;
HostIdMap = FILTER HostIdMap BY host is not null and host != '';

-- top domains
HostIdMap = FOREACH HostIdMap GENERATE DOMAIN(host) as host, id;

--skip/filter by timestamp
Graph = FILTER Graph BY timestamp matches '$I_DATE_FILTER';

Links = FOREACH Graph GENERATE src, timestamp, FLATTEN(dests) as dst;
Links = FOREACH Links GENERATE src, dst;

-- remove self loops
Links = FILTER Links BY src!=dst;
Links = DISTINCT Links;

--Replace srcids with corresponding host
SrcHostLinks = Join HostIdMap BY id, Links BY src;
SrcHostLinks = FOREACH SrcHostLinks GENERATE HostIdMap::host as srcHost, Links::dst as dst;

--Replace dstids with corresponding host
HostLinks = Join HostIdMap BY id, SrcHostLinks BY dst;
HostLinks = FOREACH HostLinks GENERATE SrcHostLinks::srcHost as srcHost, HostIdMap::host as dstHost;

HostLinksGrp = GROUP HostLinks BY (srcHost,dstHost);
HostLinksGrp = FOREACH HostLinksGrp GENERATE FLATTEN(group) as (srcHost,dstHost), COUNT(HostLinks) as count;

STORE HostLinksGrp into '$O_DOMAIN_GRAPH_DIR';
