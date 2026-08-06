#!/usr/bin/env bash -exuo pipefail
mkdir -p output
##mkdir -p tmp/asncache/
##prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i ....  -oseq-ids /dev/null -split-sequences

echo "accept.ftable_annot" > annotation.mft

locus_track  -nogenbank   -annotset annotation.mft -gc DO2_collapsed_polished-gencoll.asn -lxr fake_lxr.tsv  -o_loci ./output/locus_track.rpt -o_conflicts ./output/conflicts.rpt -o_evidence ./output/evidence.rpt
