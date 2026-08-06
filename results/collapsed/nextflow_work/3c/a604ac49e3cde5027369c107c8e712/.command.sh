#!/usr/bin/env bash -exuo pipefail
mkdir -p output
echo "accept.ftable_annot"  > models.mft
extract_products -input-manifest models.mft -it -ifmt seq-annot -rna-ids output/rna.ids -prot-ids output/prot.ids
