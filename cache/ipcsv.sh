#!/usr/bin/env bash

# transform IP latlong data into CSV
grep -v '"",""' | sed "s@,@\t@" | sed "s@\"@@g" | cut -f1,2,3 | sed "s@\t@,@g"
