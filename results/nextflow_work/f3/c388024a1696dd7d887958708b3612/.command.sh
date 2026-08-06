#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo "" > softmask.mft
printf "\nwinmask.asnb" >> softmask.mft
combine_blast_db -input-manifest softmask.mft -o output/default_softmask.asnb   -blast-algo-program 100 -blast-algo-options 'GPIPE&NCBI%2DGPipe%2DSoftmask&&Foreign%20Contamination'
