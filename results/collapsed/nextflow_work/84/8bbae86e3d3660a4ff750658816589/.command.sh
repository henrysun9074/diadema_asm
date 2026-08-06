#!/usr/bin/env bash -exuo pipefail
echo "" > evidence_denylist.mft
echo "" > gap_fill_allowlist.mft
echo "list.seqids" > scaffolds.mft
echo "7586.trusted_proteins.gi" > trusted_genes.mft
# HACK: derive start_job_id from job file extension
filename=$(basename -- "job.000")
extension="${filename##*.}"
(( start_job_id = ((10#$extension) * 491319) + 1 ))

mkdir -p tmp
# make the local LDS of the genomic and protein (if present) sequences
##lds2_indexer -source indexed -db tmp/LDS2
mkdir -p tmp/asncache/
auto_prime_cache.py -cache tmp/asncache/ -i indexed/DO2_collapsed_polished.asn -oseq-ids spidsg -split-sequences
auto_prime_cache.py -cache tmp/asncache/ -i indexed/7586.proteins.asn -oseq-ids spidsp -split-sequences


mkdir -p tmp/interim
chainer_wnode -altfrac 80.0 -capgap 5 -cdsbonus 0.05 -composite 10000 -end-pair-support-cutoff 0.1 -endprotfrac 0.05 -filters 'remove_single_exon_est_models remove_single_exon_noncoding_models' -high-identity 0.98 -hmaxlen 0.25 -hthresh 0.02 -i3p 14.0 -i5p 7.0 -lenpen 0.005 -longenoughcds 900 -max-extension 20 -min-consensus-support 2 -min-edge-coverage 5 -min-non-consensussupport 10 -min-support-fraction 0.03 -minex 10 -mininframefrac 0.95 -minlen 165 -minpolya 6 -minprotfrac 0.9 -minscor 25.0 -minsupport 3 -minsupport_mrna 1 -minsupport_rnaseq 5 -mrnaCDS use_objmgr -oep 10 -protcdslen 450 -sharp-boundary 0.2 -tolerance 3 -trim 6 -utrclipthreshold 0.01 -filterest -filtermrna -filterprots -opposite -collapsest -start-job-id $start_job_id  -workers 8 -input-jobs job.000 -O tmp/interim -nogenbank -asn-cache tmp/asncache/ -evidence-denylist-manifest evidence_denylist.mft -gap-fill-allowlist-manifest gap_fill_allowlist.mft -param 105358.params -scaffolds-manifest scaffolds.mft -trusted-genes-manifest trusted_genes.mft
mkdir -p output
cat tmp/interim/* > output/chainer_wnode.1.gpx-job.asnb
rm -rf tmp
