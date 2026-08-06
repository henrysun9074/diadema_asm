#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo "winmask.asnb" > softmask.mft
printf "\nrfam_rrna_masks.asnb" >> softmask.mft
combine_blast_db -input-manifest softmask.mft -o output/alternate_softmask.asnb   -blast-algo-program 100 -blast-algo-options 'GPIPE&windowmasker%20%2B%20Ribosomal%20RNA&&'
