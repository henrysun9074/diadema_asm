#!/bin/bash
#SBATCH --job-name=blobtools
#SBATCH --output=/work/hs325/diadema/scripts/logs/blob.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/blob.err
#SBATCH --partition=schultzlab
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
conda activate btk

### oyster
fa="/work/hs325/diadema/results/collapsed/complete.genomic.fna"
busco=/work/hs325/diadema/results/collapsed/busco/run_metazoa_odb10/full_table.tsv

cd /work/hs325/diadema/results
blobtools create --fasta $fa DiademaDir
blobtools add --busco $busco DiademaDir

# BTK_API_PORT=8880 BTK_PORT=8881 BTK_FILE_PATH=BlobDir ./blobtoolkit-api
# BTK_API_PORT=8880 BTK_PORT=8881 ./blobtoolkit-viewer

### make plots
blobtk snail \
  --blobdir DiademaDir \
  --output diademasnail.svg
