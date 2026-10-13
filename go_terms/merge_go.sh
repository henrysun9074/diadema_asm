#!/bin/bash
#SBATCH --job-name=mergego
#SBATCH --partition=scavenger
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --output=/work/hs325/diadema/scripts/logs/mergego.out
#SBATCH --error=/work/hs325/diadema/scripts/logs/mergego.err
#SBATCH --mem=64G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=hs325@duke.edu

source /hpc/group/schultzlab/hs325/miniconda3/etc/profile.d/conda.sh
cd /work/hs325/diadema/go_terms

##################### uncomment if not done yet
# wget https://purl.obolibrary.org/obo/go/go-basic.obo

# get the Spurpuratus GO terms
# mkdir -p spur && cd spur
# base=https://download.echinobase.org/echinobase
# wget $base/GenePageReports/GeneGoTerms.txt
# wget $base/GenePageReports/NcbiProteinEchinobaseGene_Spur.txt
# wget $base/Genomics/Spur5.0/sp5_0_GCF_proteins.fa.gz
# cd ..
##########################################

# run diamond for the spur stuff
# conda activate synteny 
# S="singularity exec -B /work eggnog-mapper.sif"
# FMT="6 qseqid sseqid pident length qlen slen evalue bitscore"

# $S diamond makedb --in spur/sp5_0_GCF_proteins.fa.gz -d spur/spur
# $S diamond makedb --in dant_prot.faa -d dant

# $S diamond blastp -q dant_prot.faa -d spur/spur -o dant_vs_spur.tsv \
#    --outfmt $FMT --evalue 1e-5 --max-target-seqs 5 --more-sensitive \
#    --threads ${SLURM_CPUS_PER_TASK}
# $S diamond blastp -q spur/sp5_0_GCF_proteins.fa.gz -d dant -o spur_vs_dant.tsv \
#    --outfmt $FMT --evalue 1e-5 --max-target-seqs 5 --more-sensitive \
#    --threads ${SLURM_CPUS_PER_TASK}

########### make protein to gene map
# e.g. gnl|WGS:ZZZZ|DANT_004159-P1 -> DANT_004159
grep '>' dant_prot.faa | sed 's/^>//; s/ .*//' \
  | awk '{g=$1; sub(/-P[0-9]+$/,"",g); sub(/^gnl[|]WGS:ZZZZ[|]/,"",g); print $1"\t"g}' \
  > prot2gene.tsv

# do the ortholog transfer at gene level to remove isoforms
python3 transfer_go.py --go spur/GeneGoTerms.txt \
    --spur-map spur/NcbiProteinEchinobaseGene_Spur.txt \
    --fwd dant_vs_spur.tsv --rev spur_vs_dant.tsv \
    --map prot2gene.tsv --out diadema_spur_go.tsv
# S. purpuratus genes with GO terms: 19945
# Diadema genes with a filtered best hit: 15684
# Reciprocal best hits (1:1): 11142
# RBH genes receiving GO terms: 9664

###### some checks
# wc -l *.tsv # 9664 diadema_spur_go 
# grep -c '>' dant_prot.faa #21151 total CDS
# cut -f1 dant_vs_spur.tsv | sort -u | wc -l # 20127 had a hit in Spur
# cut -f1 spur_vs_dant.tsv | sort -u | wc -l # 35116 had a hit in Dant

### after we've got all the GO terms from IPS/Eggnog -- run this
## pannzer results http://ekhidna2.biocenter.helsinki.fi/barcosel/tmp//VSzE7vs0y7J/index.html
python3 merge_go.py \
    --emapper emapper_out/diadema.emapper.annotations \
    --ips     ips_out/dant_prot.faa.tsv \
    --pannzer anno.out \
    --ortho   diadema_spur_go.tsv \
    --map     prot2gene.tsv \
    --obo     go-basic.obo \
    --out     diadema_go
