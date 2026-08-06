#!/usr/bin/env bash -exuo pipefail
echo list.seqids > seqids.mft
mkdir -p tmp/asncache
prime_cache -cache tmp/asncache -ifmt asnb-seq-entry -i DO2_hap1.asnb -oseq-ids spids -split-sequences
mkdir -p output
make_winmask_stats -logfile ./mws.log -nogenbank -asn-cache tmp/asncache -gc-assembly DO2_hap1-gencoll.asn -input-manifest seqids.mft -out output/DO2_hap1.winmask_stats  -infmt seqids -sformat binary -mem 16384 -smem 1024 -use-stored-stats never
cat ./mws.log
rm -rf tmp
