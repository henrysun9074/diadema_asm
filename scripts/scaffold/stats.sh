#!/bin/bash
#SBATCH --job-name=ragtagstats
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --output=/work/hs325/diadema/scripts/logs/ragtagstats.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/ragtagstats.err
#SBATCH --mem=100G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

# Assemblies
collapsed="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
corrected="/work/hs325/diadema/results/ragtag/ragtag.correct.fasta"
corrected_scaffolded="/work/hs325/diadema/results/ragtag/scaffolded/ragtag.scaffold.fasta"

outdir="/work/hs325/diadema/results/ragtag/qc"
mkdir -p "$outdir"

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
cd /work/hs325/diadema/results/ragtag/qc


########################################
# BUSCO
########################################

# conda activate syri_stable

# seqkit seq -w 80 \
#     "$corrected" \
#     > "/work/hs325/diadema/results/ragtag/ragtag.correct.wrapped.fasta"
# corrected="/work/hs325/diadema/results/ragtag/ragtag.correct.wrapped.fasta"

# conda activate busco

# export _JAVA_OPTIONS="-Xmx50g"

# busco \
#     -i "$corrected" \
#     -o corrected_busco \
#     -m genome \
#     -l metazoa_odb10 \
#     --force \
#     -c 10 

# busco \
#     -i "$corrected_scaffolded" \
#     -o corrected_scaffolded_busco \
#     -m genome \
#     -l metazoa_odb10 \
#     -c 10 

########################################
# QUAST
########################################

# conda activate quast

# quast.py \
#     "$corrected" \
#     "$corrected_scaffolded" \
#     -o "$outdir/quast" \
#     -t 10 \
#     --labels "v1.1,v1.2"


########################################
# GAP STATISTICS
########################################

gap_stats="$outdir/gap_stats.tsv"

printf "Assembly\tNumber_of_gaps\tTotal_gap_bases\n" > "$gap_stats"

for asm in "$collapsed" "$corrected" "$corrected_scaffolded"; do

    name=$(basename "$asm")

    num_gaps=$(grep -v '^>' "$asm" | \
        tr -d '\n' | \
        grep -o -i 'N\+' | \
        wc -l)

    gap_bases=$(grep -v '^>' "$asm" | \
        tr -d '\n' | \
        grep -o -i 'N' | \
        wc -l)

    printf "%s\t%s\t%s\n" \
        "$name" \
        "$num_gaps" \
        "$gap_bases" >> "$gap_stats"

done
