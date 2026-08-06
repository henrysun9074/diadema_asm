#!/usr/bin/env bash -exuo pipefail
mkdir -p tmp/interim
mkdir -p tmp/asncache
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i DO2_collapsed_polished.asnb -oseq-ids spids -split-sequences
filename=$(basename -- "job.000")
extension="${filename##*.}"
(( start_job_id = ((10#$extension) * 2051) + 1 ))
winmasker_wnode -ustat DO2_collapsed_polished.winmask_stats -asn-cache tmp/asncache/ -workers 8 -start-job-id $start_job_id -input-jobs job.000 -nogenbank  -O tmp/interim  > /dev/null 2> /dev/null
mkdir -p mask
cat tmp/interim/* > mask/winmasker_wnode.1.gpx-job.asnb
rm -rf tmp
