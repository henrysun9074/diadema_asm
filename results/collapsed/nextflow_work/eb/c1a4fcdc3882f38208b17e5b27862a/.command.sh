#!/usr/bin/env bash -exuo pipefail
mkdir -p tmp/asncache/
    prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i gnomon_wnode.out -oseq-ids spids -split-sequences
    prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i swissprot.asnb -oseq-ids spids2 -split-sequences

    echo "added_scores_general.txt
added_scores_RNAseq.txt" > scores.mft
    echo "hits.diamond.asn" > naming_db_secondary_support.mft
    echo "" > search_set_secondary_support.mft
    echo "best_protein_hits.asnb" > best_naming_hits.mft
    
    gnomon_filter_models -models gnomon_wnode.out -nogenbank -naming-db-support-filter 'pct_coverage >= 70 AND align_length >= 100 AND symmetric_overlap >= 75' -search-set-support-filter 0=1 -cap-and-polya-markup -quality gnomon_quality_report.txt -asn-cache tmp/asncache/  -o scored.models.asn             -scores-manifest scores.mft -prot-naming-hits best_naming_hits.mft              -search-set-secondary-support search_set_secondary_support.mft -naming-db-secondary-support naming_db_secondary_support.mft 
    rm -rf tmp
