#!/usr/bin/env bash

declare -A assembly_sizes
for s in DO2_collapsed_polished-SRR29948272-Aligned.out.Sorted.bam DO2_collapsed_polished-SRR24973326-Aligned.out.Sorted.bam DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam; do
    chunk_size=`wc -c ${s} | awk '{print $1}'`
    # Select assembly name
    s=$(basename ${s})
    regex1="^(.+)-([^-]+)-Aligned[.]out[.]Sorted[.]bam$"
    regex2="^(unpacked)_(genome)[.]bam$"
    if [[ $s =~ $regex1 ]]; then
        assembly="${BASH_REMATCH[1]}"
    elif [[ $s =~ $regex2 ]]; then
        assembly="GCF_030936135.1_lcl"
    else
        echo "Malformed BAM name, ${s}"
        exit 1
    fi
    # Update assembly -> total_size map
    echo "Assembly: ${assembly}, chunk size: ${chunk_size}"
    if [[ -z "${assembly_sizes[${assembly}]}" ]]; then
        assembly_sizes[${assembly}]=${chunk_size}
    else
        assembly_sizes[${assembly}]=$((assembly_sizes[${assembly}] + chunk_size))
    fi
done
declare -p assembly_sizes > assembly_sizes.hash
