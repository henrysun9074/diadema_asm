#!/usr/bin/env bash -exuo pipefail
download_params=''
if [ -n "busco_downloads/lineages/metazoa_odb10" ]; then
    download_params="--download_path busco_downloads --offline"
fi

num_threads=$(($(nproc) < 64 ? $(nproc) : 64))

# Set OPENBLAS_NUM_THREADS=1 because otherwise the number of threads is 32*num_threads,
# which will hit the ulimit (typically 1024). That's on top of nextflow itself using ~200 threads.
export OPENBLAS_NUM_THREADS=1

busco --version

if ! busco $download_params -i EGAPx_Test_Assembly_EGAPx_Test_Assembly.prot.fa --out output --mode proteins --cpu $num_threads --lineage_dataset metazoa_odb10 --tar; then

    # if busco errored-out, that's not a fatal failure for the pipeline.
    # Instead, just add stub outputs. NB: log, if exists, is in output/logs/busco.log
    mkdir -p output
    touch output/short_summary.json
    touch output/short_summary.txt
fi
