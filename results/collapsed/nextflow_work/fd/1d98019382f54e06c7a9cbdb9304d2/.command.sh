#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmpout
found_afbs=(0)
for af in asn_inputs/*
do
    afb=$(basename $af)
    found_afbs+=(${afb})
    annotwriter  -nogenbank -i ${af} -format gff3 -o tmpout/${afb}.genomic.gff
    annotwriter  -nogenbank -i ${af} -format gtf -o tmpout/${afb}.genomic.gtf
    asn2fasta -nogenbank -i ${af} -nucs-only |sed -e 's/^>lcl|\(.*\)/>\1/' > tmpout/${afb}.genomic.fna
    asn2fasta -nogenbank -i ${af} -feats rna_fasta -o tmpout/${afb}.transcripts.fna
    asn2fasta -nogenbank -i ${af} -feats fasta_cds_na -o tmpout/${afb}.cds.fna
    asn2fasta -nogenbank -i ${af} -prots-only -o tmpout/${afb}.proteins.faa
done
##echo 'D: ' ${found_afbs[@]}
cat `find tmpout -name g*.gff -o -name all_unannot*.genomic.gff` > output/complete.genomic.gff
cat `find tmpout -name g*.gtf -o -name all_unannot*.genomic.gtf` > output/complete.genomic.gtf
cat `find tmpout -name g*.genomic.fna -o -name all_unannot*.genomic.fna` > output/complete.genomic.fna
cat `find tmpout -name g*.transcripts.fna -o -name all_unannot*.transcripts.fna` > output/complete.transcripts.fna
cat `find tmpout -name g*.cds.fna -o -name all_unannot*.cds.fna` > output/complete.cds.fna
cat `find tmpout -name g*.proteins.faa -o -name all_unannot*.proteins.faa` > output/complete.proteins.faa
rm -rf tmpout
touch output/complete.genomic.gff
touch output/complete.genomic.gtf
touch output/complete.genomic.fna
touch output/complete.transcripts.fna
touch output/complete.cds.fna
touch output/complete.proteins.faa
