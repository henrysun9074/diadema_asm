#!/bin/bash
#SBATCH --job-name=alignment_array
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --array=1-150%20
#SBATCH --output=/work/hs325/diadema/scripts/logs/align_%a.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/align_%a.err
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

mkdir -p "${RESULTS_DIR}"

declare -A assemblies

assemblies[collapsed]="/work/hs325/diadema/ref/DO2_collapsed_polished.fa"
assemblies[corrected_scaffolded]="/work/hs325/diadema/results/ragtag/scaffolded/ragtag.scaffold.fasta"
assemblies[hap1]="/work/hs325/diadema/ref/DO2_hap1.fa"
assemblies[hap2]="/work/hs325/diadema/ref/DO2_hap2.fa"

mapfile -t R1_FILES < <(
    find "${TRIM_DIR}" -maxdepth 1 -type f -name '*_R1*.fastq.gz' | sort
)

N_SAMPLES=${#R1_FILES[@]}

echo "Number of samples found: ${N_SAMPLES}"
if (( SLURM_ARRAY_TASK_ID > N_SAMPLES )); then
    echo "Array task ${SLURM_ARRAY_TASK_ID} exceeds number of samples (${N_SAMPLES})."
    echo "Nothing to do."
    exit 0
fi

r1="${R1_FILES[$((SLURM_ARRAY_TASK_ID - 1))]}"
r2="${r1/_R1/_R2}"

if [[ ! -f "${r2}" ]]; then
    echo "ERROR: R2 file not found for:"
    echo "${r1}"
    echo "Expected:"
    echo "${r2}"
    exit 1
fi

filename=$(basename "${r1}")
sample="${filename%%_R1*}"

echo "============================================================"
echo "Sample: ${sample}"
echo "R1:     ${r1}"
echo "R2:     ${r2}"
echo "Task:   ${SLURM_ARRAY_TASK_ID}"
echo "CPUs:   ${SLURM_CPUS_PER_TASK}"
echo "============================================================"

for asm in collapsed corrected_scaffolded hap1 hap2; do

    echo
    echo "------------------------------------------------------------"
    echo "Assembly: ${asm}"
    echo "Sample:   ${sample}"
    echo "------------------------------------------------------------"

    index_prefix="${INDEX_DIR}/${asm}"
    outdir="${RESULTS_DIR}/${asm}"

    mkdir -p "${outdir}"

    bam="${outdir}/${sample}.bam"
    log="${outdir}/${sample}.hisat2.log"

    if [[ -s "${bam}" ]]; then
        echo "BAM already exists and is non-empty:"
        echo "${bam}"
        echo "Skipping ${sample} -> ${asm}"
        continue
    fi

    if [[ -e "${bam}" ]]; then
        echo "Removing incomplete/empty BAM:"
        echo "${bam}"
        rm -f "${bam}"
    fi

    echo "Aligning ${sample} -> ${asm}"
    echo "Output: ${bam}"
    echo "Log:    ${log}"
    hisat2 \
        -p "${SLURM_CPUS_PER_TASK}" \
        -x "${index_prefix}" \
        -1 "${r1}" \
        -2 "${r2}" \
        2> "${log}" \
    | samtools view \
        -@ "${SLURM_CPUS_PER_TASK}" \
        -b \
        -o "${bam}" \
        -

    echo "Finished ${sample} -> ${asm}"

done

echo
echo