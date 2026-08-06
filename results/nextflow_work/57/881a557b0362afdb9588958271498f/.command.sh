#!/usr/bin/env bash -exuo pipefail
echo list.seqids > seqids.mft
mkdir -p tmp/asncache
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i DO2_hap1.asnb -oseq-ids spids -split-sequences

gpx_qsubmit -batch-size 1 -ids-manifest seqids.mft -o jobs -nogenbank -asn-cache tmp/asncache/
total_lines=$(wc -l <jobs)
(( lines_per_file = ($total_lines + 1 - 1) / 1 ))
echo total_lines=$total_lines, lines_per_file=$lines_per_file
# split -l$lines_per_file jobs job. -da 3
# Use round robin to distribute jobs across nodes more evenly
if [ $total_lines -lt 1 ]; then
    effective_njobs=$total_lines
else
    effective_njobs=1
fi
split -nr/$effective_njobs jobs job. -da 3
rm -rf tmp

# capture process environment
set +u
cd "$NXF_TASK_WORKDIR"
echo lines_per_file=${lines_per_file[@]} > .command.env
