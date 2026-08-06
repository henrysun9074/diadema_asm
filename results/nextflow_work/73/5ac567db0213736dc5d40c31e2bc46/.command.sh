#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo "" > rfam.mft
gp_annot_format -input-manifest rfam.mft -ifmt seq-entry -ofmt tabular -o output/rfam_rrna.tab -nogenbank
