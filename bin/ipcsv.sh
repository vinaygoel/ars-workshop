#!/usr/bin/env bash
# transform IP latlong data into CSV
grep -v '"",""' | tr ',' '\t' | sed "s@\"@@g" | cut -f1-3 | tr '\t' ','
