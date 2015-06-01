#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import string

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
def collectBagElements(bag, separator=', '):
   elements = []
   for word in bag:
      elements.append(word[0])
   return separator.join(elements)

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
