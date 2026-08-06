#!/usr/bin/env bash -exuo pipefail
mkdir -p output
    mkdir -p tmp
    samtools=$(which samtools)
    if [ DO2_collapsed_polished-SRR29948272-Aligned.out.Sorted.bam DO2_collapsed_polished-SRR24973326-Aligned.out.Sorted.bam DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam == "unpacked_genome.bam" ]; then
        mv unpacked_genome.bam GCF_030936135.1_lcl-SRR10853086-Aligned.out.bam
        echo "GCF_030936135.1_lcl-SRR10853086-Aligned.out.bam" > bam_list.mft
    else
        echo "DO2_collapsed_polished-SRR29948272-Aligned.out.Sorted.bam
DO2_collapsed_polished-SRR24973326-Aligned.out.Sorted.bam
DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam" > bam_list.mft
    fi
    rnaseq_divide_by_strandedness -work-area tmp -align-manifest bam_list.mft -metadata sra_metadata.dat  -min-aligned 1000000 -min-unambiguous 200 -min-unambiguous-pct 2 -max-unambiguous-pct 100 -percentage-threshold 98  -samtools-executable $samtools -stranded-output output/stranded.list -strandedness-output output/run.strandedness -unstranded-output output/unstranded.list
    rm -rf tmp
