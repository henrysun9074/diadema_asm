#!/bin/bash
#SBATCH --job-name=eggnog
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --output=/work/hs325/diadema/scripts/logs/eggnog.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/eggnog.err
#SBATCH --mem=64G
#SBATCH --time=7-00:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

cd /work/hs325/diadema/go_terms

############ try doing these beforehand

# pull for eggnog
# singularity build eggnog-mapper.sif docker://nanozoo/eggnog-mapper:2.1.13--c16a7d2

# check version
# singularity run eggnog-mapper.sif emapper.py --version

# download data
singularity run eggnog-mapper.sif download_eggnog_data.py --data_dir ./eggnog_db

# run eggnog