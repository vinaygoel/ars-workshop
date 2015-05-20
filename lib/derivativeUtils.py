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

def parse_entity_map(entity_string):
    entity_string = entity_string.replace('{','')
    entity_string = entity_string.replace('}','')
    entity_string = entity_string.replace('=[', '=')
    entity_string = entity_string.replace('], ','],')
    entity_list = re.split(r'],?', entity_string)
    return entity_list
