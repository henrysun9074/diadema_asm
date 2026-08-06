#!/usr/bin/env bash -exuo pipefail
gpx_qdump -unzip '*' -slices-for affinity -sort-by affinity  -input-path inputs -output gnomon_wnode.out
