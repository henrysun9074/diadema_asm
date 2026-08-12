#!/bin/bash
#SBATCH --job-name=alignment
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --output=/work/hs325/diadema/scripts/logs/align.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/align.err
#SBATCH --mem=100G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

set -euo pipefail

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
conda activate RNA-seq
module load HISAT2

RNASEQ_DIR="/work/hs325/diadema/ref/rnaseq"
TRIM_DIR="${RNASEQ_DIR}/trimmed"
RESULTS_DIR="/work/hs325/diadema/results/aligned"
INDEX_DIR="/work/hs325/diadema/ref/hisat2_indexes"

mkdir -p "${TRIM_DIR}" "${RESULTS_DIR}" "${INDEX_DIR}"

cd "${RNASEQ_DIR}"

declare -A assemblies
assemblies[collapsed]="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
assemblies[corrected_scaffolded]="/work/hs325/diadema/results/ragtag/scaffolded/ragtag.scaffold.fasta"
assemblies[hap1]="/work/hs325/diadema/ref/DO2_hap1.fa"
assemblies[hap2]="/work/hs325/diadema/ref/DO2_hap2.fa"

echo "=== Running fastp ==="

for r1 in *_R1*.fastq.gz; do
    [[ -e "${r1}" ]] || continue
    r2="${r1/_R1/_R2}"
    if [[ -f "${r2}" ]]; then
        sample="${r1%%_R1*}"
        out1="${TRIM_DIR}/${r1}"
        out2="${TRIM_DIR}/${r2}"
        echo "Trimming paired-end sample: ${sample}"
        fastp \
            -i "${r1}" \
            -I "${r2}" \
            -o "${out1}" \
            -O "${out2}" \
            > "${TRIM_DIR}/${sample}.fastp.log" 2>&1
    fi
done

echo "=== Building/checking HISAT2 indexes ==="

for asm in "${!assemblies[@]}"; do

    fasta="${assemblies[$asm]}"
    index_prefix="${INDEX_DIR}/${asm}"

    if [[ ! -f "${fasta}" ]]; then
        echo "ERROR: Assembly not found: ${fasta}" >&2
        exit 1
    fi

    # HISAT2 indexes can be .ht2 or .ht2l.
    if [[ ! -f "${index_prefix}.1.ht2" && \
          ! -f "${index_prefix}.1.ht2l" ]]; then

        echo "Building HISAT2 index for ${asm}"

        hisat2-build \
            "${fasta}" \
            "${index_prefix}"
    else
        echo "HISAT2 index already exists for ${asm}; skipping."
    fi

done

echo "=== Running HISAT2 alignments ==="

for asm in "${!assemblies[@]}"; do

    echo "Assembly: ${asm}"

    index_prefix="${INDEX_DIR}/${asm}"
    outdir="${RESULTS_DIR}/${asm}"

    mkdir -p "${outdir}"

    for r1 in "${TRIM_DIR}"/*_R1*.fastq.gz; do
        [[ -e "${r1}" ]] || continue

        r2="${r1/_R1/_R2}"

        [[ -f "${r2}" ]] || continue

        filename=$(basename "${r1}")
        sample="${filename%%_R1*}"

        bam="${outdir}/${sample}.bam"
        log="${outdir}/${sample}.hisat2.log"

        echo "Aligning ${sample} -> ${asm}"

        hisat2 \
            -x "${index_prefix}" \
            -1 "${r1}" \
            -2 "${r2}" \
            2> "${log}" \
        | samtools view -b -o "${bam}" -

    done

done

echo "=== All alignments complete ==="