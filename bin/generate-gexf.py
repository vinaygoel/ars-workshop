#!/usr/bin/python
'''
Generate a GEXF file from (src, dst, weight) triples
'''
import csv
import sys

domains = []
domain_ids = {}
edges = []
for row in csv.reader(sys.stdin, delimiter='\t'):
   src, dst, weight = row[0], row[1], row[2]
   for domain in (src, dst):
      if domain not in domain_ids:
         domain_ids[domain] = len(domains)
         domains.append(domain)
    
   src_id, dst_id = domain_ids[src], domain_ids[dst]
   edges.append((src_id,dst_id,float(weight)))

print """<?xml version="1.0" encoding="UTF8"?>
<gexf xmlns="http://www.gexf.net/1.2draft" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd"
  version="1.2">
  <meta lastmodifieddate="2015-06-01">
    <creator>ARS Workshop</creator>
    <description>Graph File</description>
  </meta>
  <graph defaultedgetype="directed">
    <nodes>"""

for i, domain in enumerate(domains):
   print "      <node id=\"%d\" label=\"%s\"/>" % (i, domain)

print "    </nodes>"
print "    <edges>"

edge_id = 0
for edge in edges:
    print ("      <edge id=\"%d\" source=\"%d\" target=\"%d\" weight=\"%.2f\"/>" %
       (edge_id, edge[0], edge[1], edge[2]))
    edge_id += 1
print "    </edges>"
print "  </graph>"
print "</gexf>"
