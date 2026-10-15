#!/bin/bash
#SBATCH --job-name=interproscan
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --output=/work/hs325/diadema/scripts/logs/interproscan.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/interproscan.err
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

module load Java/23.0.1
cd /work/hs325/diadema/go_terms
mkdir -p interproscan_data ips_out ips_work

export NXF_APPTAINER_CACHEDIR=/work/hs325/diadema/go_terms/apptainer_cache
export NXF_SINGULARITY_CACHEDIR=$NXF_APPTAINER_CACHEDIR
mkdir -p $NXF_APPTAINER_CACHEDIR

# keep apptainer's own layer cache and build temp off $HOME and /tmp
export APPTAINER_CACHEDIR=/work/hs325/diadema/go_terms/apptainer_cache/layers

# build temp must be on local disk
export APPTAINER_TMPDIR=$(mktemp -d ${TMPDIR:-/tmp}/apptainer.XXXXXX)
trap 'rm -rf "$APPTAINER_TMPDIR"' EXIT
export SINGULARITY_CACHEDIR=$APPTAINER_CACHEDIR
export SINGULARITY_TMPDIR=$APPTAINER_TMPDIR
mkdir -p $APPTAINER_CACHEDIR $APPTAINER_TMPDIR

nextflow run ebi-pf-team/interproscan6 \
  -r 6.0.2.2 \
  -resume 17565694-a20c-486b-a4f2-acce5b66671d \
  -profile apptainer \
  -w ./ips_work \
  --input /work/hs325/diadema/go_terms/dant_prot.faa \
  --datadir /work/hs325/diadema/go_terms/interproscan_data \
  --interpro 110.0 \
  --outdir ./ips_out \
  --goterms \
  --pathways \
  --cpus 4 \
  --max-workers 4