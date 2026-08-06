#!/usr/bin/env bash -exuo pipefail
mkdir -p output
curl -fL --retry 5 -C - -o SRR24973326.sra $(srapath SRR24973326)
fasterq-dump --skip-technical --threads 6 --split-files --seq-defline ">gnl|SRA|\$ac.\$si.\$ri" --fasta --outdir output  ./SRR24973326.sra
ls output/SRR24973326_*.fasta
rm -f SRR24973326.sra
