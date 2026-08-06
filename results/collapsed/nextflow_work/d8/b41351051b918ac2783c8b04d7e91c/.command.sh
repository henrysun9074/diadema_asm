#!/usr/bin/env bash -exuo pipefail
mkdir -p out
if [[ -n ${TMPDIR-} ]]; then
    mkdir -p ${TMPDIR} || true
fi

#temporarily for development for faster turn-around
#cat inp/seqids.tsv | tail -n 2 > tmp_seqids.tsv

run_wnode_batch.py                                                  \
    --exclusive                                                     \
    --batch-num=11                                         \
    --num-batches=16                                    \
    --ids=inp/seqids.tsv                                            \
    --asn-cache=inp/asn_cache                                       \
    --work-dir=./var                                                \
    --out-file=out/11.gpx-job.asnb                         \
    cmsearch_wnode                                                  \
        -exclusive-threshold 1000000000                             \
        -cpus-per-worker 8                                          \
        -cmsearch-cpu 32                                            \
        -cmsearch-path   $(dirname $(which cmsearch))             \
        -model-path      inp/cmsearch_data/rfam1410.cm              \
        -rfam-amendments inp/cmsearch_data/rfam1410_amendments.xml  \
        -rfam-stockholm  inp/cmsearch_data/Rfam.seed                \
        -rfam-version    14.10                                      \
        -truncate_terminal_Ns                                       \
