#!/usr/bin/env sh


# Install ARS_App and launch
cd ARS_App
sudo perl Makefile.PL
sudo make test
sudo make install

plackup -E deployment -s Starman -p 3000 -a bin/app.pl &

curl http://localhost:3000/api/v1/ars

# Install java clients
cd ../client-java
mvn install

# Install perl clients
cd ../client-perl
sudo perl Makefile.PL
sudo make test


