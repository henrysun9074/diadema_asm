#!/usr/bin/env bash -exuo pipefail
samtools=`which samtools`
if [ `stat -L -c%s DO2_collapsed_polished-bin78.bam` -lt 100000 ] && [ `$samtools view -c DO2_collapsed_polished-bin78.bam` -eq 0 ]; then
    exit 0
fi
mkdir -p tmp/sam
if [[ -n ${TMPDIR-} ]]; then
    mkdir -p ${TMPDIR} || true
fi
if [[ -n ${TEMP-} ]]; then
    mkdir -p ${TEMP} || true
fi

lds2_indexer -source genome/ -db tmp/LDS2
sam2asn -filter 'pct_identity_gap >= 95' -ofmt seq-align-compressed -collapse-identical -no-scores -ifmt bam -pseudo-run-accessions sra_metadata.dat -refs-local-by-default  -nogenbank -lds2 tmp/LDS2 -tmp-dir tmp/sam -align-counts "DO2_collapsed_polished-bin78.align_counts.txt" -o "DO2_collapsed_polished-bin78.align.asnb.gz" -strandedness run.strandedness -input DO2_collapsed_polished-bin78.bam -samtools-path $samtools
rm -rf
