#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp
lds2_indexer -source indexed -db tmp/lds_index
align_filter -filter 'rank=1 OR (pct_identity_gapopen_only > 58 AND (pct_coverage > 50 OR align_length_ungap > 1000))' -ifmt seq-align  -lds2 tmp/lds_index  -nogenbank -input align.asn -output output/align.asn -non-match-output output/align-nomatch.asn -report-output output/report.txt 
rm -rf tmp
