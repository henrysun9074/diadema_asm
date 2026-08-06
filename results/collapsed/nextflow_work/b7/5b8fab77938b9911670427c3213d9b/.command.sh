#!/usr/bin/env bash -exuo pipefail
mkdir -p output
curl -fL --retry 5 -C - -o SRR24973327.sra $(srapath SRR24973327)
fasterq-dump --skip-technical --threads 6 --split-files --seq-defline ">gnl|SRA|\$ac.\$si.\$ri" --fasta --outdir output  ./SRR24973327.sra
ls output/SRR24973327_*.fasta
rm -f SRR24973327.sra
