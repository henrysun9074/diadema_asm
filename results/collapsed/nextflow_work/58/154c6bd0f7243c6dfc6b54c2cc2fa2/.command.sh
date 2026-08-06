#!/usr/bin/env bash -exuo pipefail
set -exuo pipefail

# Prepare config-file.
mkdir -p inp
cat > inp/annot_builder.ini << \
---------------------------------------------------------------------------
[Main]
accept_dir = "out/ACCEPT"
collection_dir = "out/COLLECTION"
conflict_dir = "out/CONFLICT"
loss_pct_ccds = "0.0"
loss_pct_refseq_alt_ref_loci = "100.0"
loss_pct_refseq_other = "1.0"
loss_pct_refseq_patches = "100.0"
loss_pct_refseq_ref_primary = "1.0"
report_dir = "out/REPORT"
test_dir = "out/TEST"

---------------------------------------------------------------------------

# Append GNOMON-config if present.

# Note: a reasonable thing to do would be to unconditionally create 
# the config file with all possible DataProviders, and simply specify
# empty `input_manifest` files when those inputs are not connected,
# which works, but it will emit all data-provider names into the output ASN.1,
# including the ones that are not connected.
#
# Hence we'll need to conditionally populate the config instead.

if [[ -n "inp/scored.models.asn" ]]; then
    ls inp/scored.models.asn > inp/gnomon_annots.mft

    cat >> inp/annot_builder.ini << \
---------------------------------------------------------------------------
[DataProvider01]
input_manifest = "inp/gnomon_annots.mft" 
aliases = "Gnomon|Chainer|PartAbInitio|FullAbInitio|Chainer_GapFilled|PartAbInitio_GapFilled"
desc = "Gnomon"
name = "gnomon"
model_maker = "gnomon2model"
drop_alt_brs_overlap = "1"
enable_AR0050_AR0048 = "1"
is_primary = "1"
keep_top_N_models = "50"
max_pct_ab_initio = "50"
merge_variants = "1"
use_secondary_support = "1"

---------------------------------------------------------------------------
fi

# Append cmsearch-config if present
if [[ -n "inp/cmsearch.asnb" ]]; then
    ls inp/cmsearch.asnb > inp/cmsearch_annots.mft

    cat >> inp/annot_builder.ini << \
---------------------------------------------------------------------------
[DataProvider02]
aliases = "Rfam"
desc = "cmsearch"
input_manifest = "inp/cmsearch_annots.mft"
is_primary = "1"
model_maker = "gnomon2model"
name = "rfam"

---------------------------------------------------------------------------
fi

# Append tRNA-config if present
if [[ -n "inp/trnascan.asnb" ]]; then
    ls inp/trnascan.asnb > inp/trna_annots.mft

    cat >> inp/annot_builder.ini << \
---------------------------------------------------------------------------
[DataProvider03]
desc = "tRNAscan-SE"
input_manifest = "inp/trna_annots.mft"
is_primary = "1"
model_maker = "passthru"
name = "trna"

---------------------------------------------------------------------------
fi


mkdir -p out/{ACCEPT,COLLECTION,CONFLICT,REPORT,TEST}

mkdir -p tmp/asncache
prime_cache -cache tmp/asncache/ -ifmt asn-seq-entry -i inp/DO2_collapsed_polished.asn -split-sequences

annot_builder -version
annot_builder -accept-output both -nogenbank -asn-cache tmp/asncache/ -conffile inp/annot_builder.ini -gc-assembly inp/DO2_collapsed_polished-gencoll.asn -logfile out/annot_builder.log

# NB: don't do this because if there are many files (aberrant assembly with many scaffolds),
# *-expansion will exceed maximum command-line length. Instead, use find with -exec.
# cat out/ACCEPT/*.ftable.annot > out/ACCEPT/accept.ftable_annot

find out/ACCEPT -type f -name '*.ftable.annot' -exec cat {} + > out/ACCEPT/accept.ftable_annot
rm -rf tmp
