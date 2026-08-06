#!/usr/bin/env bash -exuo pipefail
set -exuo pipefail
mkdir -p out/
zcat -f inp/fasta.fa | prime_cache -ifmt fasta -cache out/asn_cache -oseq-ids out/seqids.tsv
