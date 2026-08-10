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

dant_asm="/work/hs325/diadema/ref/dsetosum/Diadema_setosum_genomic.fna"
dset_asm="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"

result="/work/hs325/diadema/results/ragtag"
result2="/work/hs325/diadema/results/ragtag/scaffolded"
mkdir -p $result
mkdir -p $result2

# [reference] [query]
ragtag.py correct $dset_asm $dant_asm -o $result
ragtag.py scaffold $dset_asm $result/ragtag.correct.fasta -o $result2

###### stats
asm=$result2"/ragtag.scaffold.fasta"
ragtag.py asmstats $asm
ragtag.py updategff \
    "/work/hs325/diadema/results/collapsed/complete.genomic.gff" \
    $result2/"ragtag.scaffold.agp"