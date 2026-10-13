#!/bin/bash
#SBATCH --job-name=eggnog
#SBATCH --partition=schultzlab
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --output=/work/hs325/diadema/scripts/logs/eggnog.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/eggnog.err
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

cd /work/hs325/diadema/go_terms

############ do these beforehand

# pull for eggnog
# singularity build eggnog-mapper.sif docker://nanozoo/eggnog-mapper:2.1.13--c16a7d2

# check version
# singularity run eggnog-mapper.sif emapper.py --version

# download data
# cd /work/hs325/diadema/go_terms/eggnog_db
# this database moved -- no longer eggnogdb.embl.de
# base=http://eggnog5.embl.de/download/emapperdb-5.0.2

# wget $base/eggnog.db.gz            && gunzip eggnog.db.gz
# wget $base/eggnog.taxa.tar.gz      && tar -xzf eggnog.taxa.tar.gz && rm eggnog.taxa.tar.gz
# wget $base/eggnog_proteins.dmnd.gz && gunzip eggnog_proteins.dmnd.gz

# check its there
ls -lh /work/hs325/diadema/go_terms/eggnog_db

############

# run eggnog
mkdir -p /work/hs325/diadema/go_terms/emapper_out
TMP=/work/hs325/diadema/go_terms/tmp
mkdir -p $TMP

singularity exec eggnog-mapper.sif emapper.py \
    -i /work/hs325/diadema/go_terms/dant_prot.faa \
    --itype proteins \
    -m diamond \
    --data_dir ./eggnog_db \
    --output diadema \
    --output_dir ./emapper_out \
    --cpu ${SLURM_CPUS_PER_TASK} \
    --go_evidence all \
    --dbmem \
    --temp_dir $TMP