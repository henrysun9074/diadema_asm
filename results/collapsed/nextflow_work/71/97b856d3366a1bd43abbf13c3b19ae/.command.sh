#!/usr/bin/env bash -exuo pipefail
echo "default_softmask.asnb" > softmask_data.mft
mkdir -p tmp/asncache
prime_cache -cache tmp/asncache -ifmt asnb-seq-entry -i DO2_collapsed_polished.asnb -oseq-ids spids -split-sequences
mkdir -p output
gc_makeblastdb -nogenbank -asn-cache tmp/asncache -gc-assembly DO2_collapsed_polished-gencoll.asn -input list.seqids -softmask-manifest softmask_data.mft -output-manifest output/blastdb.mft -output-path output -title 'BLASTdb created by EGAPx'
rm -rf tmp
