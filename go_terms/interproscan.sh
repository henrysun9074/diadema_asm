#!/bin/bash
#SBATCH --job-name=interproscan
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --output=/work/hs325/diadema/scripts/logs/interproscan.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/interproscan.err
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

cd /work/hs325/diadema/go_terms

nextflow run ebi-pf-team/interproscan6 \
  -r 6.0.2.2 \
  -profile apptainer \
  --input /work/hs325/diadema/go_terms/dant_prot.faa \
  --datadir /work/hs325/diadema/go_terms/interproscan_data \
  --interpro 110.0
  