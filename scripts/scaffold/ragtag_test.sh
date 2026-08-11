#!/bin/bash
#SBATCH --job-name=ragtag
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --output=/work/hs325/diadema/scripts/logs/ragtag.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/ragtag.err
#SBATCH --mem=100G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
 
conda activate ragtag

######### haplotype 1
dant_asm="/work/hs325/diadema/ref/dsetosum/Diadema_setosum_genomic.fna"
dset_asm="/work/hs325/diadema/ref/DO2_hap1.fa"

result="/work/hs325/diadema/results/ragtag/reverse"
mkdir -p $result

# [reference] [query]
ragtag.py scaffold $dant_asm $dset_asm -o $result

###### stats
asm="$result/ragtag.scaffold.fasta"
ragtag.py asmstats $asm
