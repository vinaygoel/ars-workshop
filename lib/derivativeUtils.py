#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import string
import com.xhaus.jyson.JysonCodec as json

@outputSchema("entities:tuple(persons:bag{p:tuple(person:chararray)},organizations:bag{o:tuple(organization:chararray)}, locations:bag{l:tuple(location:chararray)})")
def get_entity_bags(entity_string):
    ner_dict = { 'PERSON': [], 'ORGANIZATION': [], 'LOCATION': [] }
    for entity_line in parse_entity_map(entity_string):
        entity_parts = entity_line.split('=')
        if len(entity_parts) >= 2:
            entity_type = entity_parts[0]
            entity_val_str = "".join(entity_parts[1:])
            entity_vals = re.split(r', *', entity_val_str)
            if entity_type in ner_dict:
                ner_dict[entity_type] = entity_vals
    data_tuple = (ner_dict['PERSON'], ner_dict['ORGANIZATION'], ner_dict['LOCATION'])
    return data_tuple

@outputSchema("text:chararray") 
def WaneWriter(url, timestamp, digest, entity_string):
    entity_data_tuple = get_entity_bags(entity_string)
    persons = entity_data_tuple[0]
    organizations = entity_data_tuple[1]
    locations = entity_data_tuple[2]
    entities = dict()
    entities['persons'] = persons
    entities['organizations'] = organizations
    entities['locations'] = locations
    result = dict()
    result['url'] = url
    result['timestamp'] = timestamp
    result['digest'] = digest
    result['named_entities'] = entities
    result_json = json.dumps(result)
    return result_json

@outputSchema("text:chararray")
def LgaIdMapWriter(id, url, surt_url):
    result = dict()
    result['url'] = url
    result['surt_url'] = surt_url
    result['id'] = id
    result_json = json.dumps(result)
    return result_json

@outputSchema("text:chararray")
def LgaIdGraphWriter(id, timestamp, outlink_ids_set):
    result = dict()
    result['id'] = id
    result['timestamp'] = timestamp
    result['outlink_ids'] = [x[0] for x in outlink_ids_set]
    result_json = json.dumps(result)
    return result_json

@outputSchema("text:chararray") 
def collectBagElements(bag, separator=', '):
    elements = []
    for word in bag:
        elements.append(word[0])
    return separator.join(elements)

@outputSchema('links:bag{t:(link:chararray)}')
def generateBagFromArray(arrayString):
    if arrayString is not None:
        arrayString = arrayString[1:-1]
        bag = [ (c,) for c in arrayString.split(',')  ]
        return bag
    return None

def parse_entity_map(entity_string):
     entity_string = entity_string.replace('{','')
     entity_string = entity_string.replace('}','')
     entity_string = entity_string.replace('=[', '=')
     entity_string = entity_string.replace('], ','],')
     entity_list = re.split(r'],?', entity_string)
     return entity_list

@outputSchema("text:chararray")
def getClassicTSFormatFromWARCTS(timestamp):
    if not timestamp or len(timestamp) <= 19:
        return None
    return re.sub("[^0-9]", "", timestamp[:19])

@outputSchema("text:chararray") 
def getDateFormatFromWARCTS(timestamp):
    if not timestamp or len(timestamp) <= 14:
        return None
    return timestamp[0:10]

@outputSchema("text:chararray")
def getTLDFromDomain(domain):
    if not domain:
        return None
    domainParts = domain.split('.')
    domainParts.reverse()
    tld = domainParts[0]
    return tld


@outputSchema("text:chararray")
def getHostFromSurtUrl(surtUrl):
    host = None
    if not surtUrl:
        return None
    surtUrlParts = surtUrl.split('/')
    surtHost = surtUrlParts[0]
    #strip away any text after whitespace
    surtHostParts = surtHost.split()
    if len(surtHostParts) == 0:
        return None
    surtHost = surtHostParts[0]
    #strip away port number
    surtHostParts = surtHost.split(':')
    surtHost = surtHostParts[0]
    surtHost = remove_chars(surtHost)
    surtHostParts = surtHost.split(',')
    surtHostParts.reverse()
    host = '.'.join(surtHostParts)
    return host

def remove_chars(to_translate, translate_to=u''):
    chars_to_remove = u'()'
    translate_table = dict((ord(char), translate_to) for char in chars_to_remove)
    return to_translate.translate(translate_table)
