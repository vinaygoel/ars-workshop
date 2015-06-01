#!/usr/bin/env bash
# geoip wrapper script
tar -xzf geo-pack.tgz
PERL5LIB=$PERL5LIB:$(pwd) 
./ipToLatLong.pl GeoLiteCity.dat 
