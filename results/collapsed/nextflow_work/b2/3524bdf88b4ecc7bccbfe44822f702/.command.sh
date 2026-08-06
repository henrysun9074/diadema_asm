#!/usr/bin/env bash -exuo pipefail
mkdir -p out

run_wnode_batch.py                                                  \
    --exclusive                                                     \
    --batch-num=11                                         \
    --num-batches=16                                    \
    --ids=inp/seqids.tsv                                            \
    --asn-cache=inp/asn_cache                                       \
    --work-dir=./var                                                \
    --out-file=out/11.gpx-job.asnb                         \
    trnascan_wnode                                                  \
        -X 55 -Q -b -q -tRNAscan $(which tRNAscan-SE) \
