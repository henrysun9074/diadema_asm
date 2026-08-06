#!/usr/bin/env bash -exuo pipefail
mkdir -p output
curl -fL --retry 5 -C - -o SRR29948272.sra $(srapath SRR29948272)
fasterq-dump --skip-technical --threads 6 --split-files --seq-defline ">gnl|SRA|\$ac.\$si.\$ri" --fasta --outdir output  ./SRR29948272.sra
ls output/SRR29948272_*.fasta
rm -f SRR29948272.sra
