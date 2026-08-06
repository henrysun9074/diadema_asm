#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp/asncache
for f in input/*; do
    echo $f >> input.mft
done
prime_cache -cache tmp/asncache -input-manifest input.mft -ifmt asn-seq-entry
gnomon_asn2fasta -nogenbank -asn-cache tmp/asncache -gc-assembly gencoll.asn -ifmt seq-entry -input-manifest input.mft -prot-output output/@.prot.fa -prot-output-manifest output/proteins.mft -it -one-per-gene -primary-only -separate-by-unit
rm -rf tmp
