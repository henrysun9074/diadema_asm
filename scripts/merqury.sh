#!/bin/bash
#SBATCH --job-name=merqury_qv
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --output=/work/hs325/diadema/scripts/logs/merqury_qv.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/merqury_qv.err

set -euo pipefail

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
conda activate assembly

# use illumina short reads
R1="/work/hs325/diadema/ref/raw/illumina/SRR32478703_1.fastq.gz"
R2="/work/hs325/diadema/ref/raw/illumina/SRR32478703_2.fastq.gz.gz"

k=21

assemblies=(
    "/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
    "/work/hs325/diadema/results/ragtag/ragtag.correct.fasta"
    "/work/hs325/diadema/results/ragtag/scaffolded/ragtag.scaffold.fasta"
)

# make k-mer db
outdir="/work/hs325/diadema/results/merqury"
mkdir -p "$outdir"

read_db="$outdir/reads.meryl"

if [[ ! -d "$read_db" ]]; then

    echo "Building read k-mer database..."

    meryl k="$k" count \
        output "$read_db" \
        "$R1" "$R2"

else
    echo "Using existing Meryl database:"
    echo "$read_db"
fi

# run merqury
for asm in "${assemblies[@]}"; do

    name=$(basename "$asm")
    name="${name%.fasta}"
    name="${name%.fa}"
    name="${name%.fna}"

    result="$outdir/$name"
    mkdir -p "$result"

    echo "====================================="
    echo "Running Merqury: $name"
    echo "Assembly: $asm"
    echo "====================================="

    merqury.sh \
        "$read_db" \
        "$asm" \
        "$result/$name"

done
