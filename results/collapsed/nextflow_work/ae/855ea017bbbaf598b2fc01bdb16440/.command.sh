#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp
lds2_indexer -source indexed -db tmp/lds2_index
echo "aligns.4.paf" > input.mft
paf2asn -prosplign-refinement -lds2 tmp/lds2_index -nogenbank -input-manifest input.mft |
    align_filter -u -nogenbank | # deduplicate - GP-40550
    cat > output/aligns.4.asn
rm -rf tmp
