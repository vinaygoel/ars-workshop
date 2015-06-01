/* Input: LGA Dataset
 * Output:  Generate a domain graph dataset that contains the following tab-separated fields: source_domain, destination_domain and num_links, where num_links is the number of links from pages of the source_domain to pages in the destination_domain.
 */

%default I_LGA_DIR '';
%default I_DATE_FILTER '^201.*$';
%default O_DOMAIN_GRAPH_DIR '';
%default LIB_DIR 'lib/';
REGISTER '$LIB_DIR/derivativeUtils.py' using jython as derivativeUtils;
REGISTER lib/ia-porky-jar-with-dependencies.jar;
DEFINE DOMAIN org.archive.porky.ExtractTopPrivateDomainFromHostNameUDF();

IDMap = LOAD '$I_LGA_DIR/id.map.gz/' as (id:chararray, url:chararray);
Graph = LOAD '$I_LGA_DIR/id.graph.gz/' as (src:chararray, timestamp:chararray, dests:{dest:(dst:chararray)});

HostIdMap = FOREACH IDMap GENERATE derivativeUtils.getHostFromSurtUrl(url) as host, id;
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
