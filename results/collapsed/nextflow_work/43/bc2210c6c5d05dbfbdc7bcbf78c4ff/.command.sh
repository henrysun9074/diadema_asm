#!/usr/bin/env bash -exuo pipefail
mkdir -p output
    mkdir -p tmp
    lds2_indexer -source indexed -db tmp/lds_index
    echo "aligns.1.asn
aligns.3.asn
aligns.4.asn
aligns.2.asn" > align.mft

    sort align.mft > rm_me.tmp
    mv rm_me.tmp align.mft

    best_placement -asm_alns_filter 'reciprocity = 3'  -lds2 tmp/lds_index  -nogenbank  -gc_path DO2_collapsed_polished-gencoll.asn -in_alns align.mft -out_alns output/align.asn -out_rpt  output/report.txt
    rm -rf tmp
