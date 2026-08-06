#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp
lds2_indexer  -db tmp/lds -source input
sqlite3 tmp/lds "SELECT txt_id FROM seq_id WHERE orig=1 AND int_id IS NULL;" > output/swiss_prot_ids
rm -rf tmp
