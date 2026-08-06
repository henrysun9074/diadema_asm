#!/usr/bin/env bash -exuo pipefail
mkdir -p output

cp genomic.fna.gz output/ref_genomic.fna.gz
cp protein.faa.gz output/ref_protein.faa.gz
cp name_from_ortholog.rpt output/name_from_ortholog.rpt

gunzip output/ref_genomic.fna.gz
gunzip output/ref_protein.faa.gz
zcat genomic.gff.gz | multireader -format gff3 | gzip -c > output/ref_genomic.gff.asnt.gz
