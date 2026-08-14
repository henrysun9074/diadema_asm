#!/bin/bash
#SBATCH --job-name=ragtagstats
#SBATCH --partition=common
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
# corrected="/work/hs325/diadema/results/ragtag/ragtag.correct.fasta"
corrected_scaffolded="/work/hs325/diadema/results/ragtag/scaffolded/filtered.fasta"
# reverse="/work/hs325/diadema/results/ragtag/reverse/ragtag.scaffold.fasta"
hap1_v2="/work/hs325/diadema/results/ragtag/hap1/ragtag.correct.fasta"
hap2_v2="/work/hs325/diadema/results/ragtag/hap2/ragtag.correct.fasta"

outdir="/work/hs325/diadema/results/ragtag/qc"
mkdir -p "$outdir"

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
cd /work/hs325/diadema/results/ragtag/qc

########################################
# BUSCO
########################################

# conda activate syri_stable

# seqkit seq -w 80 \
#     "$corrected_scaffolded" \
#     > "/work/hs325/diadema/results/ragtag/scaffolded/ragtag.correct.wrapped.fasta"
# reverse="/work/hs325/diadema/results/ragtag/scaffolded/ragtag.correct.wrapped.fasta"

conda activate busco

export _JAVA_OPTIONS="-Xmx50g"

busco \
    -i "$corrected_scaffolded" \
    -o corrected_scaffolded_busco \
    -m genome \
    -l metazoa_odb10 \
    --force \
    -c 10 

# busco \
#     -i "$hap1_v2" \
#     -o corrected_scaffolded_busco_hap1 \
#     -m genome \
#     -l metazoa_odb10 \
#     --force \
#     -c 10 

# busco \
#     -i "$hap2_v2" \
#     -o corrected_scaffolded_busco_hap2 \
#     -m genome \
#     -l metazoa_odb10 \
#     --force \
#     -c 10 

########################################
# QUAST
########################################

conda activate quast

quast.py \
    "$collapsed" \
    "$corrected_scaffolded" \
    -o "$outdir/quast" \
    -t 10 \
    --labels "collapsed,corrected_scaffolded"

# quast.py \
#     "$hap1_v2" \
#     "$hap2_v2" \
#     -o "$outdir/quast_haps" \
#     -t 10 \
#     --labels "hap1_v2,hap2_v2"

########################################
# GAP STATISTICS
########################################

gap_stats="$outdir/gap_stats.tsv"

printf "Assembly\tNumber_of_gaps\tTotal_gap_bases\n" > "$gap_stats"

for asm in "$collapsed" "$corrected_scaffolded" "$hap1_v2" "$hap2_v2"; do

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

####################### command line w/ seqkit 
# conda activate syri_stable

# cd /work/hs325/diadema/results/ragtag/scaffolded
# seqkit fx2tab --length --name --header-line filtered.fasta > filtered_contig_lengths.txt
