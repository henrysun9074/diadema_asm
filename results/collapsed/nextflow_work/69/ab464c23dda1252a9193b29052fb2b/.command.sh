#!/usr/bin/env bash -exuo pipefail
mkdir -p tmp/asncache
prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i gnomon_wnode.out -oseq-ids spids2 -split-sequences
prime_cache -cache tmp/asncache/ -ifmt asn-seq-entry  -i DO2_collapsed_polished.asn -oseq-ids spids -split-sequences
if [[ -n "7586.proteins.asn" ]]; then
    if [[ `head -c4 7586.proteins.asn` == "Seq-" ]]; then
        prime_cache -cache tmp/asncache/ -ifmt asn-seq-entry -i 7586.proteins.asn -oseq-ids spids3 #-split-sequences
    else
        prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry -i 7586.proteins.asn -oseq-ids spids3 #-split-sequences
    fi
fi
echo "gnomon_wnode.out" > models.mft
gnomon_summary -egapx -models models.mft -nogenbank -max-outliers 20  -input gnomon_report.txt -quality gnomon_quality_report.txt -asn-cache tmp/asncache/  -output All.gnomon_evidence_@.txt

touch All.gnomon_evidence_bag.txt
touch All.gnomon_evidence_pair.txt
touch All.gnomon_evidence_stats.txt
touch All.gnomon_evidence_taxid.txt
rm -rf tmp
