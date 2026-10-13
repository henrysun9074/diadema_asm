#!/bin/bash
#SBATCH --job-name=sra
#SBATCH --partition=schultzlab
#SBATCH --output=/work/hs325/diadema/scripts/logs/sra.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/sra.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=2-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

module load SRA-Toolkit/3.0.0-rhel8

cd /work/hs325/diadema/ref/raw

# hifi 
# prefetch SRR32365430
cd hifi
fasterq-dump SRR32365430 \
    --split-files \
    --threads 8 \
    --outdir .

######################
echo
# illumina 
# cd ../illumina
# fasterq-dump SRR32478703 \
#     --split-files \
#     --threads 8 \
#     --outdir .

echo
cd ../nanopore
fasterq-dump SRR32479314 \
    --split-files \
    --threads 8 \
    --outdir .

fasterq-dump SRR32463885 \
    --split-files \
    --threads 8 \
    --outdir .