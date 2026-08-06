#!/usr/bin/env bash -exuo pipefail
mkdir -p output
    mkdir -p tmp
    lds2_indexer -source indexed -db tmp/lds_index
    echo "align.1.out
sorted_aligns.asn" > alignments.mft
    align_sort  -merge -nogenbank -ifmt seq-align -compression none -k subject,subject_start,-subject_end -rnaseq-uniq -strip-alignment -tmp tmp -input-manifest alignments.mft  -o output/sorted_aligns.asn  -lds2 tmp/lds_index
    rm -rf tmp
