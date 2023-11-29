#!/bin/bash

set -ex

Rscript -e "install.packages(c('TMB', 'sn', 'rootSolve', 'extraDistr'))"

make

cp *.RData /output/
#cp *.html /output/
