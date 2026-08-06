#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp
lds2_indexer -source indexed -db tmp/lds_index
echo "align.asn" > alignments.mft
align_sort  -nogenbank -limit-mem 13G -k subject,subject_start,-subject_end,subject_strand,query,query_start,-query_end,query_strand,-num_ident,gap_count -tmp tmp -input-manifest alignments.mft  -o output/sorted_aligns.asn  -lds2 tmp/lds_index
rm -rf tmp
