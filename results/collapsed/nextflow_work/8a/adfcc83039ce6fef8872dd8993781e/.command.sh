#!/usr/bin/env bash
if [[ -n ${TMPDIR-} ]]; then
    mkdir -p ${TMPDIR} || true
fi
if [[ -n ${TEMP-} ]]; then
    mkdir -p ${TEMP} || true
fi

mkdir -p output
echo "bam file : DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam, index file : DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam.csi"
s=$(basename DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam)
regex1="^(.+)-([^-]+)-Aligned[.]out[.]Sorted[.]bam$"
regex2="^(unpacked)_(genome)[.]bam$"
if [[ $s =~ $regex1 ]]; then
    assembly="${BASH_REMATCH[1]}"
    run="${BASH_REMATCH[2]}"
elif [[ $s =~ $regex2 ]]; then
    assembly="GCF_030936135.1_lcl"
    run="testing"
else
    echo "Malformed BAM name, DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam"
    exit 1
fi

source assembly_sizes.hash
total_size=${assembly_sizes[$assembly]}
echo "Assembly $assembly, run $run, total size $total_size"

echo "genome DO2_collapsed_polished.fasta"
head -5 DO2_collapsed_polished.fasta
echo "organelle "
head -5 
echo "DO2_collapsed_polished.fasta" > genome.mft
echo "" > organelle.mft
samtools=`which samtools`
bam_bin -file-pattern 'bin#.bam' -avg-size-per-bin 200000000 -exclude-organelle -bam DO2_collapsed_polished-SRR24973327-Aligned.out.Sorted.bam -o output/$assembly-$run.bins -total-bam-size $total_size         -fasta-manifest genome.mft -organelle-manifest organelle.mft -samtools-path $samtools
