#!/bin/bash
#SBATCH --job-name=ragtagstats_haps
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --output=/work/hs325/diadema/scripts/logs/ragtagstatshaps.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/ragtagstatshaps.err
#SBATCH --mem=100G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

# Assemblies
dset="/work/hs325/diadema/ref/dsetosum/Diadema_setosum_genomic.fna"
collapsed="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
corrected_hap1="/work/hs325/diadema/results/ragtag/hap1/ragtag.correct.fasta"
corrected_scaffolded_hap1="/work/hs325/diadema/results/ragtag/hap1/scaffolded/ragtag.scaffold.fasta"
corrected_hap2="/work/hs325/diadema/results/ragtag/hap2/ragtag.correct.fasta"
corrected_scaffolded_hap2="/work/hs325/diadema/results/ragtag/hap2/scaffolded/ragtag.scaffold.fasta"

outdir="/work/hs325/diadema/results/ragtag/qc"
mkdir -p "$outdir"

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
cd /work/hs325/diadema/results/ragtag/qc

########################################
# BUSCO
########################################

########## do this if needed if BUSCO runs OOM
# conda activate syri_stable

# seqkit seq -w 80 \
#     "$corrected_hap1" \
#     > "/work/hs325/diadema/results/ragtag/hap1/ragtag.correct.wrapped.fasta"
# corrected_hap1="/work/hs325/diadema/results/ragtag/hap1/ragtag.correct.wrapped.fasta"

# seqkit seq -w 80 \
#     "$corrected_hap2" \
#     > "/work/hs325/diadema/results/ragtag/hap2/ragtag.correct.wrapped.fasta"
# corrected_hap1="/work/hs325/diadema/results/ragtag/hap2/ragtag.correct.wrapped.fasta"

conda activate busco

# export _JAVA_OPTIONS="-Xmx50g"

busco \
    -i "$corrected_hap1" \
    -o corrected_busco_hap1 \
    -m genome \
    -l metazoa_odb10 \
    --force \
    -c 10 

busco \
    -i "$corrected_scaffolded_hap1" \
    -o corrected_scaffolded_busco_hap1 \
    -m genome \
    -l metazoa_odb10 \
    -c 10 

busco \
    -i "$corrected_hap2" \
    -o corrected_busco_hap2 \
    -m genome \
    -l metazoa_odb10 \
    --force \
    -c 10 

busco \
    -i "$corrected_scaffolded_hap2" \
    -o corrected_scaffolded_busco_hap2 \
    -m genome \
    -l metazoa_odb10 \
    -c 10 

########################################
# QUAST
########################################

# conda activate quast

quast.py \
    "$corrected_hap1" \
    "$corrected_scaffolded_hap1" \
    -o "$outdir/quast_hap1" \
    -t 10 \
    --labels "hap1_v1.1,hap1_v2"

quast.py \
    "$corrected_hap2" \
    "$corrected_scaffolded_hap2" \
    -o "$outdir/quast_hap2" \
    -t 10 \
    --labels "hap2_v1.1,hap2_v2"

quast.py \
    "$dset" \
    "$collapsed" \
    -o "$outdir/quast_oldasms" \
    -t 10 \
    --labels "dset,dantcollapsed"


########################################
# GAP STATISTICS
########################################

gap_stats="$outdir/gap_stats_haps.tsv"

printf "Assembly\tNumber_of_gaps\tTotal_gap_bases\n" > "$gap_stats"

for asm in "$corrected_hap1" "$corrected_hap2" "$corrected_scaffolded_hap1" "$corrected_scaffolded_hap2"; do

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