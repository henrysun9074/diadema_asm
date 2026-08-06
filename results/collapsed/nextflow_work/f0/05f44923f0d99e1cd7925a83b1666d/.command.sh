#!/usr/bin/env bash -exuo pipefail
mkdir -p output
miniprot -t 8 -G 600000 -p 0.4 --outs=0.4  DO2_collapsed_polished.fasta aligns.3.faa > output/aligns.3.paf
