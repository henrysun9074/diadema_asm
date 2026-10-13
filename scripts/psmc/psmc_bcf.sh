#!/bin/bash
#SBATCH --job-name=psmc_bcf
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --output=/work/hs325/diadema/scripts/logs/psmc_bcf.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/psmc_bcf.err
#SBATCH --mem=100G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

module load bcftools
module load samtools/1.3.1
module load Minimap2 
which psmc

set -euo pipefail

cd /work/hs325/diadema/results/psmc

asm="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
bam="sorted.bam"

samtools depth -a sorted.bam |
awk '{
    s += $3
    n++
    if ($3 > 0) {
        c++
        sc += $3
    }
}
END {
    print "mean depth =",s/n
    print "fraction covered =",c/n
    print "mean covered depth =",sc/c
}'

cut -f1 "${asm}.fai" > contigs.txt

echo "# of contigs"
wc -l contigs.txt

contig=$(sort -k2,2nr "${asm}.fai" | head -1 | cut -f1)

echo "Testing this - $contig"

bcftools mpileup \
    -Ou \
    -f "$asm" \
    -q 30 \
    -Q 30 \
    -r "$contig" \
    "$bam" |
bcftools call \
    -c \
    -Ov \
    -o test.vcf

ls -lh test.vcf