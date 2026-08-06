#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo "default_softmask.asnb" > mask.mft
convert_mask -input-manifest mask.mft -o output/default_softmask_asnb.asnb -ifmt blast-mask -ofmt ftable -name NCBI-GPipe-Softmask -nogenbank
