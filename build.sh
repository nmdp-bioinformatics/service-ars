#!/usr/bin/env sh


# Install ARS_App and launch
cd ARS_App
perl Makefile.PL
make test
make install

plackup -E deployment -s Starman -p 3000 -a bin/app.pl &

# Install java clients
cd ../client-java
mvn install

# Install perl clients
cd ../client-perl
perl Makefile.pl
make test
make install

