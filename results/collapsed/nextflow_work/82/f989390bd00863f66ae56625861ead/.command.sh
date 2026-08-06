#!/usr/bin/env bash -exuo pipefail
mkdir -p tmp
mkdir -p tmp/asncache
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i indexed/gnomon_wnode.out -oseq-ids /dev/null -split-sequences
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i indexed/swissprot.asnb -oseq-ids /dev/null -split-sequences

mkdir -p ./output
align_sort -ifmt seq-align-set -nogenbank -limit-mem 13G -filter 'pct_coverage >= 50' -group 1 -k query,-bit_score,slen,-align_length -ofmt seq-align-set -top 1 -tmp tmp   -asn-cache tmp/asncache  -i ./input_alignments.asnb -o output/best_protein_hits.asnb

rm -rf tmp
