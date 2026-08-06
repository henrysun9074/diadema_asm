#!/usr/bin/env bash

declare -A bin_map
for run in DO2_collapsed_polished-SRR29948272.bins DO2_collapsed_polished-SRR24973326.bins DO2_collapsed_polished-SRR24973327.bins; do
    s=$(basename ${run})
    regex="^(.+)-([^-]+)[.]bins$"
    if [[ $s =~ $regex ]]; then
        assembly="${BASH_REMATCH[1]}"
    else
        echo "Malformed bins name, ${run}"
        exit 1
    fi
    for bam in $run/*.bam; do
        key="$assembly-$(basename $bam)"
        if [[ -z ${bin_map[$key]} ]]; then
            bin_map[$key]=$bam
        else
            bin_map[$key]="${bin_map[$key]} $bam"
        fi
    done
done
for bin in ${!bin_map[@]}; do
    echo "merge --threads 8 $bin ${bin_map[$bin]}" >$bin.bin_args
done
