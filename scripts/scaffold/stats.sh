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
dset="/work/hs325/diadema/ref/dsetosum/Diadema_setosum_genomic.fna"
collapsed="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
corrected="/work/hs325/diadema/results/ragtag/ragtag.correct.fasta"
corrected_scaffolded="/work/hs325/diadema/results/ragtag/scaffolded/ragtag.scaffold.fasta"
reverse="/work/hs325/diadema/results/ragtag/reverse/ragtag.scaffold.fasta"

outdir="/work/hs325/diadema/results/ragtag/qc"
mkdir -p "$outdir"

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
cd /work/hs325/diadema/results/ragtag/qc

########################################
# BUSCO
########################################

conda activate syri_stable

seqkit seq -w 80 \
    "$reverse" \
    > "/work/hs325/diadema/results/ragtag/reverse/ragtag.correct.wrapped.fasta"
reverse="/work/hs325/diadema/results/ragtag/reverse/ragtag.correct.wrapped.fasta"

conda activate busco

# export _JAVA_OPTIONS="-Xmx50g"

busco \
    -i "$reverse" \
    -o reverse_busco \
    -m genome \
    -l metazoa_odb10 \
    --force \
    -c 10 

# busco \
#     -i "$corrected_scaffolded" \
#     -o corrected_scaffolded_busco \
#     -m genome \
#     -l metazoa_odb10 \
#     -c 10 

########################################
# QUAST
########################################

conda activate quast

quast.py \
    "$collapsed" \
    "$reverse" \
    -o "$outdir/quast_reverse" \
    -t 10 \
    --labels "collapsed,reverse"

# quast.py \
#     "$dset" \
#     "$collapsed" \
#     -o "$outdir/quast_oldasms" \
#     -t 10 \
#     --labels "dset,dantcollapsed"

########################################
# GAP STATISTICS
########################################

gap_stats="$outdir/gap_stats_reverse.tsv"

printf "Assembly\tNumber_of_gaps\tTotal_gap_bases\n" > "$gap_stats"

for asm in "$collapsed" "$reverse"; do

    name=$(basename "$asm")

    awk -v name="$name" '
    BEGIN {
        gaps = 0
        gap_bases = 0
        in_gap = 0
    }

    /^>/ {
        # A gap cannot continue across FASTA records
        in_gap = 0
        next
    }

    {
        for (i = 1; i <= length($0); i++) {
            base = substr($0, i, 1)

            if (base == "N" || base == "n") {
                gap_bases++

                if (!in_gap) {
                    gaps++
                    in_gap = 1
                }
            } else {
                in_gap = 0
            }
        }
    }

    END {
        printf "%s\t%d\t%d\n", name, gaps, gap_bases
    }
    ' "$asm" >> "$gap_stats"

done