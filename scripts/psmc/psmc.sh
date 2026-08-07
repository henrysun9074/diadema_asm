#!/bin/bash
#SBATCH --job-name=psmc
#SBATCH --partition=common
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --output=/work/hs325/diadema/scripts/logs/psmc.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/psmc.err
#SBATCH --mem=50G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu


# load software
module load bcftools
module load samtools
module load Minimap2 
which psmc

mkdir -p /work/hs325/diadema/results/psmc
cd /work/hs325/diadema/results/psmc

hifi="/work/hs325/diadema/ref/raw/hifi/SRR32365430.fastq"
asm="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"

# align and index bam
minimap2 -ax map-hifi $asm $hifi | samtools sort -o sorted.bam

## generate diploid consensus
samtools mpileup -C50 -uf assembly.fa sorted.bam | \
bcftools call -c - | \
vcfutils.pl vcf2fq -d 9 -D 56 | gzip > diploid.fq.gz ### use 28x coverage so -d is x/3, -D is 2x

## convert to PSMC input
fq2psmcfa -q20 diploid.fq.gz > diploid.psmcfa

# run psmc model and plot
psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o diploid.psmc diploid.psmcfa

# mutation rate of 1.2e-5 and generation time of 1 year
psmc_plot.pl -u 1.2e-5 -g 1 -p diploid_lower_bound diploid.psmc

# mutation rate of 1.9e-5 and generation time of 2 years
psmc_plot.pl -u 1.9e-5 -g 2 -p diploid_upper_bound diploid.psmc