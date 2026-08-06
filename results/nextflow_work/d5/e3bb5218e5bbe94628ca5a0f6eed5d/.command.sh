#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo winmask.asnb > winmask_data.mft
echo  > rmask_data.mft
mkdir -p tmp/asncache/
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i DO2_hap1.asnb -oseq-ids spids -split-sequences
mask_assm_stats -assembly DO2_hap1-gencoll.asn -nogenbank -rmask-output rmask_data.mft -winmask-output winmask_data.mft -output output/mask_assm_stats.xml -asn-cache tmp/asncache/
rm -rf tmp
