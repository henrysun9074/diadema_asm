#!/usr/bin/env bash -exuo pipefail
# echo "need_zcat: false, out_fasta: fasta/DO2_hap1.fasta"
mkdir -p genome
mkdir -p fasta
mkdir -p tmp/asncache

first_char=""
if [[ false == true ]]; then
    first_char=`zcat src/DO2_hap1.fa | head -c 100 | grep -oP "[[:print:]]" | head -c 1 || true`
else
    first_char=`head -c 100 src/DO2_hap1.fa | grep -oP "[[:print:]]" | head -c 1`
fi

if [[ ${first_char} == ">" ]]; then
    if [[ false == true ]]; then
        zcat src/DO2_hap1.fa | sed -r 's/>([^ |]+)( .*)?$/>lcl|\1\2/' | sed -r 's/>([^ ]+)$/>\1 title/' > fasta/DO2_hap1.fasta
    else
        sed -r 's/>([^ |]+)( .*)?$/>lcl|\1\2/' src/DO2_hap1.fa | sed -r 's/>([^ ]+)$/>\1 title/' > fasta/DO2_hap1.fasta
    fi
    multireader -flags ParseRawID -out-format asn_text -input fasta/DO2_hap1.fasta -output genome/DO2_hap1.asn
    multireader -flags ParseRawID -out-format asn_binary -input fasta/DO2_hap1.fasta -output genome/DO2_hap1.asnb
    prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i genome/DO2_hap1.asnb -oseq-ids ./cache_id_list  -split-sequences
elif [[ ${first_char} == "S" ]]; then
    if [[ false == true ]]; then
        zcat src/DO2_hap1.fa  > genome/DO2_hap1.asn
    else
        cp src/DO2_hap1.fa genome/DO2_hap1.asn
    fi
    asn_translator -i  genome/DO2_hap1.asn -o genome/DO2_hap1.asnb -b 
    prime_cache -cache tmp/asncache/ -ifmt asn-seq-entry  -i src/DO2_hap1.fa -oseq-ids ./cache_id_list  -split-sequences
    getfasta -nogenbank -asn-cache tmp/asncache/ -i ./cache_id_list  -o fasta/DO2_hap1.fasta
else 
    if [[ false == true ]]; then
        zcat src/DO2_hap1.fa  > genome/DO2_hap1.asnb
    else
        cp src/DO2_hap1.fa genome/DO2_hap1.asnb
    fi
    asn_translator -i  genome/DO2_hap1.asnb -o genome/DO2_hap1.asn  
    prime_cache -cache tmp/asncache/ -ifmt asnb-seq-entry  -i src/DO2_hap1.fa -oseq-ids ./cache_id_list  -split-sequences
    getfasta -nogenbank -asn-cache tmp/asncache/ -i ./cache_id_list  -o fasta/DO2_hap1.fasta
fi

# Old way, now use gc_get_molecules. For multipart ids with gi first use the second part
# grep -oP "^>\K[^ ]+" fasta/DO2_hap1.fasta | sed 's/^\(gi|[0-9]\+\)|\([^|]\+|[^|]\+\)|\?/\2/' >list.seqids
# Using all parts of multipart ids is preferrable, but slower - one more pass over genomic FASTA

## gc_create seq-id works with some characters that gc_create fasta does not
gc_create -unplaced ./cache_id_list -unplaced-fmt seq-id -fasta-parse-raw-id -gc-assm-name "EGAPx Test Assembly" -nogenbank -asn-cache tmp/asncache/ >DO2_hap1-gencoll.asn

gc_get_molecules -gc-assembly DO2_hap1-gencoll.asn -filter all -level top-level > list.seqids

#TODO: subtract organelles from list

# Get exact genome size using seqkit.
genome_size=`seqkit stat --tabular fasta/DO2_hap1.fasta | tail -n1 | cut -f5`
# Max intron logic
if [ 500000000 -gt 0 ] && [ $genome_size -lt 500000000 ]; then
    # scale max intron to genome size, rounding up to nearest 100kb
    (( max_intron = (600000 * genome_size / 500000000 + 99999) / 100000 * 100000 ))
    # echo "Setting max_intron to $max_intron"
else
    max_intron=600000
fi
# NB: this printout is essential for effective max_intron value to be reported
echo "max_intron $max_intron"
rm -rf tmp

# capture process environment
set +u
cd "$NXF_TASK_WORKDIR"
echo max_intron=${max_intron[@]} > .command.env
