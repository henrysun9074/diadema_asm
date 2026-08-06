#!/usr/bin/env bash -exuo pipefail
set -exuo pipefail

mkdir -p out var
gpx_qdump -input-path ./inp/gpx/ -sort-by job-id -unzip '*' |
    trnascan_dump -oasn out/trnascan.asnb -ostruc var/struc.tar.gz -X 55
