#!/bin/bash
#SBATCH --job-name=merqury_qv
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --output=/work/hs325/diadema/scripts/logs/merqury_qv.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/merqury_qv.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

set -euo pipefail

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
conda activate assembly

# short reads
R1="/work/hs325/diadema/ref/raw/illumina/SRR32478703_1.fastq.gz"
R2="/work/hs325/diadema/ref/raw/illumina/SRR32478703_2.fastq.gz"

k=21


declare -A assemblies=(
    [collapsed]="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
    [collapsed_v1.1]="/work/hs325/diadema/results/ragtag/ragtag.correct.fasta"
    [collapsed_v1.2]="/work/hs325/diadema/results/ragtag/scaffolded/ragtag.scaffold.fasta"
    [hap1]="/work/hs325/diadema/ref/DO2_hap1.fa"
    [hap2]="/work/hs325/diadema/ref/DO2_hap2.fa"
    [hap1_v2]="/work/hs325/diadema/results/ragtag/hap1/scaffolded/ragtag.scaffold.fasta"
    [hap2_v2]="/work/hs325/diadema/results/ragtag/hap2/scaffolded/ragtag.scaffold.fasta"
)

outdir="/work/hs325/diadema/results/merqury"
mkdir -p "$outdir"

# for read in "$R1" "$R2"; do
#     if [[ ! -f "$read" ]]; then
#         echo "ERROR: Read file not found:"
#         echo "$read"
#         exit 1
#     fi
# done

# for name in "${!assemblies[@]}"; do
#     asm="${assemblies[$name]}"

#     if [[ ! -f "$asm" ]]; then
#         echo "ERROR: Assembly not found:"
#         echo "$asm"
#         exit 1
#     fi
# done

# echo "All input files found."

read_db="$outdir/reads.meryl"

# if [[ ! -d "$read_db" ]]; then

#     echo "====================================="
#     echo "Building read k-mer database"
#     echo "k = $k"
#     echo "R1: $R1"
#     echo "R2: $R2"
#     echo "Output: $read_db"
#     echo "====================================="

#     meryl k="$k" count \
#         output "$read_db" \
#         "$R1" "$R2"

# else

#     echo "====================================="
#     echo "Using existing Meryl database"
#     echo "$read_db"
#     echo "====================================="

# fi

for name in "${!assemblies[@]}"; do

    asm="${assemblies[$name]}"
    result="$outdir/$name"

    mkdir -p "$result"

    echo
    echo "====================================="
    echo "Running Merqury"
    echo "Name:     $name"
    echo "Assembly: $asm"
    echo "Output:   $result"
    echo "====================================="

    (
        cd "$result"

        merqury.sh \
            "$read_db" \
            "$asm" \
            "$name"
    )

    echo "Finished Merqury: $name"

done

