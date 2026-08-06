#!/usr/bin/env bash -exuo pipefail
mkdir -p output
mkdir -p tmp/asncache
mkdir -p 'EGAPx_Test_Assembly'

prime_cache -cache tmp/asncache/ -ifmt asn-seq-entry  -i genome/DO2_collapsed_polished.asn  -oseq-ids cached_ids  -split-sequences
concat_seqentries -cache tmp/asncache/ -o "./EGAPx_Test_Assembly/genome.asnb.gz"
asn_translator -gzip -i "./EGAPx_Test_Assembly/genome.asnb.gz"  -o "./EGAPx_Test_Assembly/genome.asnt" 

echo "./EGAPx_Test_Assembly/genome.asnt" > ./scaffold.mft
touch ./chromosome.mft
ls -1 annots/* > ./annots.mft
echo locus.lnk > ./locus_link.mft
echo locustypes.tsv > ./locus_types.mft

echo "" > ./gene_weights.mft

##lds2_indexer -source genome/ -db LDS2
## prime_cache

final_asn -annot-provider 'GenBank submitter' -annot-pipeline 'NCBI EGAPx' -annot-software-version 0.5.2 -annot-name GB_2026_08_05 -annot-date 08/05/2026 -locus-tag-prefix DANT -egapx -nogenbank  -gencoll-asn gencoll.asn -asn-cache tmp/asncache/          -scaffolds ./scaffold.mft  -chromosomes ./chromosome.mft          -gene_weights ./gene_weights.mft          -annots ./annots.mft -locus_lnk ./locus_link.mft -locus_types ./locus_types.mft         -S NONE -genbank-mode -out_dir  ./output/

mkdir -p tmp/scaf
mv ./output/scaf/EGAPx_Test_Assembly/*.asn tmp/scaf
for f in tmp/scaf/*.asn; do
    of=./output/scaf/EGAPx_Test_Assembly/`basename $f`
    asn_cleanup -basic -i $f -o $of
    cat $of >> output/annotated_genome.asn
done

# NB if (when) chromosomes is not empty the same logic should be applied to chrom directroies
if [ -s ./output/chrom/EGAPx_Test_Assembly/*.asn ]; then
    mkdir -p tmp/chrom
    mv ./output/chrom/EGAPx_Test_Assembly/*.asn tmp/chrom
    for f in tmp/chrom/*.asn; do
        of=./output/chrom/EGAPx_Test_Assembly/`basename $f`
        asn_cleanup -basic -i $f -o $of
        cat $of >> output/annotated_genome.asn
    done
fi

mkdir -p output/val/EGAPx_Test_Assembly
for f in ./output/scaf/EGAPx_Test_Assembly/*.asn; do
    asnvalidate -Q 0 -asn-cache tmp/asncache/ -v 4 -A -X -Z -o ./output/val/EGAPx_Test_Assembly/`basename $f .asn`.val -i $f
done

# joint manifest is scaffolds, chromosomes, and organelles (not implemented here)
# take it from annotated_genome.asn
echo "./output/annotated_genome.asn" > ./joint.mft

mkdir -p output/stats
asn_stats -input-manifest ./joint.mft -o output/stats/feature_counts.txt -counts-xml-output output/stats/feature_counts.xml -stats-xml-output output/stats/feature_stats.xml -t -break-by assembly-unit -asn-cache tmp/asncache/ -gencoll-asn gencoll.asn -genbank-mode -nogenbank
rm -rf tmp
