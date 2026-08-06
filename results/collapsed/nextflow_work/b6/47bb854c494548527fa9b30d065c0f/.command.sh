#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo "rfam_rrna.tab" > mask.mft
convert_mask -input-manifest mask.mft -o output/rfam_rrna_masks.asnb -ifmt contaminant-mask -ofmt blast-mask -types rRNA -exclude-pseudo -blast-algo-options 'GPIPE&Ribosomal%20RNA&&' -nogenbank
