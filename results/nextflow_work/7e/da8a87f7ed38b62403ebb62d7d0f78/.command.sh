#!/usr/bin/env bash -exuo pipefail
mkdir -p output
miniprot -t 8 -G 600000 -p 0.4 --outs=0.4  DO2_hap1.fasta aligns.1.faa > output/aligns.1.paf
