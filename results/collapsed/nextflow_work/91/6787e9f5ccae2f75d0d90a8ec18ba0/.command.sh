#!/usr/bin/env bash -exuo pipefail
set -exuo pipefail

mkdir -p out
gpx_qdump -input-path ./inp/gpx/ -sort-by job-id -unzip '*' |
    annot_merge -asn-cache inp/asn_cache -output out/cmsearch.asnb -euk -unique
