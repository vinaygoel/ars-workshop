#!/usr/bin/env bash
tar -xzf geo-pack.tgz
PERL5LIB=$PERL5LIB:$(pwd) 
./ipToLatLong.pl GeoLiteCity.dat 
