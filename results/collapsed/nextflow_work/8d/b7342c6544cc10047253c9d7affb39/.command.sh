#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp/asncache/
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i swissprot.asnb  -oseq-ids /dev/null -split-sequences

lds2_indexer -source genome/ -db tmp/LDS2 
echo "best_protein_hits.asnb" > best_prot_hit.mft
extract_prot_names -alns best_prot_hit.mft  -nogenbank -o output/best_gnomon_prot_hit.tsv -asn-cache tmp/asncache/ -lds2 tmp/LDS2
echo "" > best_refseq_prot_hit.mft
extract_prot_names -alns best_refseq_prot_hit.mft -nogenbank -o output/best_refseq_prot_hit.tsv -asn-cache tmp/asncache/ -lds2 tmp/LDS2 
echo "accept.ftable_annot" > annotation.mft
echo "" > curr_prev_compare.mft
echo  ""  > comparisons.mft
str=""
str="$str -orthologs orthologs.rpt"
str="$str -lxr lxr_tracking_data.txt"
str="$str -locus_track locus_track.rpt"
str="$str -name_from_ortholog_rpt name_from_ortholog.rpt"

locus_type  -asn-cache tmp/asncache/ -lds2 tmp/LDS2 -nogenbank -no_acc_reserve -lineage '1,131567,2759,33154,33208,6072,33213,33511,7586,133551,7624,7625,7638,2341009,31172,31173,31174,105358,1316087'  -name_cleanup_rules_file name_cleanup_rules_file.txt  -annots annotation.mft -gc DO2_collapsed_polished-gencoll.asn -gnomon_biotype biotypes.tsv -o_stats output/stats.xml -o_locustypes output/locustypes.tsv -o_locus_lnk output/locus.lnk  -annotcmp comparisons.mft  -annotcmp_pb curr_prev_compare.mft $str
rm -rf tmp
