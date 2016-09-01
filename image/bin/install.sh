#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

BUILD="wget ca-certificates"
ESSENTIAL="openjdk-7-jre-headless bc"


# Build dependencies
apt-get update --yes
apt-get install --yes --no-install-recommends ${BUILD}

# Download precompiled sparse assembler
URL="https://github.com/yechengxi/SparseAssembler/raw/master/compiled/SparseAssembler"
wget ${URL} --quiet --output-document /usr/local/bin/SparseAssembler
chmod 700 /usr/local/bin/SparseAssembler


# Install bbmap for kmer and genome size estimation
BBMAP="http://downloads.sourceforge.net/project/bbmap/BBMap_36.20.tar.gz"
wget ${BBMAP} --quiet --output-document - \
  | tar xzf - --directory /usr/local/
ln -s /usr/local/bbmap/*.sh /usr/local/bin

# Clean up dependencies
apt-get autoremove --purge --yes ${BUILD}
apt-get clean

# Install essential packages for running
apt-get install --yes --no-install-recommends ${ESSENTIAL}
rm -rf /var/lib/apt/lists/*
