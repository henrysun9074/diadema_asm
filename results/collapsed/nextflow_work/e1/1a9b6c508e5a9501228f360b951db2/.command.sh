#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp/asncache/
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i swissprot.asnb -oseq-ids spids -split-sequences
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i scored.models.asn -oseq-ids gnids -split-sequences
lds2_indexer -source genome/ -db tmp/LDS2
echo "hits.diamond.asn" > raw_blastp_hits.mft
merge_blastp_hits -asn-cache tmp/asncache/ -nogenbank -lds2 tmp/LDS2 -input-manifest raw_blastp_hits.mft -o prot_hits.asn
echo "scored.models.asn" > models.mft
echo "prot_hits.asn" > prot_hits.mft
echo "" > splices.mft
effective_params=""
if [[ ! "${effective_params}" =~ "-name_cleanup_rules_file" ]]; then
    effective_params="${effective_params} -name_cleanup_rules_file name_cleanup_rules_file.txt"
fi
if [ -n "swissprot_organelle_bacteria.gi" ]; then
    effective_params="${effective_params} -prot_denylist swissprot_organelle_bacteria.gi"
fi
gnomon_biotype -lineage '1,131567,2759,33154,33208,6072,33213,33511,7586,133551,7624,7625,7638,2341009,31172,31173,31174,105358,1316087' ${effective_params} -logfile - -gc DO2_collapsed_polished-gencoll.asn -asn-cache tmp/asncache/ -lds2 tmp/LDS2  -nogenbank -gnomon_models models.mft -o output/biotypes.tsv -o_prots_rpt output/prots_rpt.tsv -o_contam_rpt output/contam_rpt.tsv -prot_hits prot_hits.mft -prot_splices splices.mft -reftrack-server 'NONE' -allow_lt631 true
rm -rf tmp
