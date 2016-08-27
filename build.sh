#!/usr/bin/env sh


# Install ARS_App and launch
cd ARS_App
sudo perl Makefile.PL
sudo make test
sudo make install

plackup -D -E deployment -s Starman -p 5000 -a bin/app.pl

# Install java clients
cd ../client-java
mvn install

# Install perl clients
cd ../client-perl
sudo perl Makefile.pl
sudo make test
sudo make install

