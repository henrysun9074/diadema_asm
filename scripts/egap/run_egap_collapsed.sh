#!/bin/bash
#SBATCH --job-name=egapx
#SBATCH --partition=common
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --output=/work/hs325/diadema/scripts/logs/egap.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/egap.err
#SBATCH --mem=16G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

module load Java/11.0.8
module load SRA-Toolkit

export PATH=$HOME/opt/nextflow-23:$PATH
nextflow -version

source /hpc/group/schultzlab/hs325/miniconda3/bin/activate egapx
export APPTAINER_CACHEDIR="/work/hs325/diadema/scripts/logs/cache"
export APPTAINER_TMPDIR="/work/hs325/diadema/scripts/logs/tmp"
export NXF_SINGULARITY_CACHEDIR="/work/hs325/diadema/scripts/logs/cache"

mkdir -p "$APPTAINER_CACHEDIR"
mkdir -p "$APPTAINER_TMPDIR"

cd /hpc/group/schultzlab/hs325/egapx

########### check internet access
echo "HOST: $(hostname)"
echo "DATE: $(date)"

python - <<'PY'
import urllib.request
print(urllib.request.urlopen("https://eutils.ncbi.nlm.nih.gov", timeout=20).status)
PY

# python ui/egapx.py \
#     /work/hs325/diadema/scripts/egap/input.yaml \
#     -e slurm \
#     -lc /work/hs325/diadema/scripts/logs/cache \
#     -o /work/hs325/diadema/results/collapsed

# python ui/egapx.py \
#     /work/hs325/diadema/scripts/egap/input2.yaml \
#     -e slurm \
#     -lc /work/hs325/diadema/scripts/logs/cache \
#     -o /work/hs325/diadema/results/hap1

python ui/egapx.py \
    /work/hs325/diadema/scripts/egap/input3.yaml \
    -e slurm \
    -lc /work/hs325/diadema/scripts/logs/cache \
    -o /work/hs325/diadema/results/corrected_scaffolded    