#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo "accept.ftable_annot"  > annotations1.mft
echo "ref_genomic.gff.asnt.gz"  > annotations2.mft
str=""
if [ -z "" ]
then
    mkdir -p tmp/asncache
    auto_prime_cache.py -cache tmp/asncache/ -i ref_protein.asnb  -oseq-ids /dev/null -split-sequences
    auto_prime_cache.py -cache tmp/asncache/ -i DO2_collapsed_polished.asnb  -oseq-ids /dev/null -split-sequences
    auto_prime_cache.py -cache tmp/asncache/ -i scored.models.asn  -oseq-ids /dev/null -split-sequences
    auto_prime_cache.py -cache tmp/asncache/ -i input/ref_genome.asn  -oseq-ids /dev/null -split-sequences
    str="-asn-cache tmp/asncache/  -prot_hits_serial_type Seq-align-set"
else
    str="-blastdb /prot.blastdb,/nucl.blastdb -prot_hits_serial_type Seq-align"
fi
echo $str
find_orthologs -check_exome -annots1_serial_type Seq-annot -annots2_serial_type Seq-annot -gc1 DO2_collapsed_polished-gencoll.asn -gc2 input/ref_gencoll.asn -annots1 annotations1.mft  -annots2 annotations2.mft $str -o_orthologs output/orthologs.rpt   -prot_hits hits.diamond.asn -o_stats output/stats.xml -nogenbank

rm -rf tmp
