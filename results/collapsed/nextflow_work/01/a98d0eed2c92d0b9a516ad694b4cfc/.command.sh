#!/usr/bin/env bash -exuo pipefail
###diamond_bin=`which diamond`
#diamond_egap uses GP_HOME to build paths to both some gp apps, and third-party
#GP_HOME needs to be the directory that contains third-party, and the directory that contains bin/<gp apps> 
diamond_bin=${GP_HOME}/third-party/diamond/diamond

mkdir -p tmp/asncache
if [[ -n ${TMPDIR-} ]]; then
    mkdir -p ${TMPDIR} || true
fi
auto_prime_cache.py -cache tmp/asncache/ -i indexed/scored.models.asn -oseq-ids /dev/null -split-sequences
auto_prime_cache.py -cache tmp/asncache/ -i indexed/ref_protein.asnb -oseq-ids /dev/null -split-sequences

mkdir -p output
mkdir -p tmp/work

echo  -blastp-args '--sam-query-len --very-sensitive --unal 0 --comp-based-stats 0 --masking 0 --max-target-seqs 100' -ofmt seq-align-set -query-fmt seq-ids -subject-fmt seq-ids -output-prefix hits
echo "prot.ids" > query.mft
diamond_egap  -blastp-args '--sam-query-len --very-sensitive --unal 0 --comp-based-stats 0 --masking 0 --max-target-seqs 100' -ofmt seq-align-set -query-fmt seq-ids -subject-fmt seq-ids -output-prefix hits  -asn-cache tmp/asncache/ -nogenbank -query-manifest query.mft -subject swiss_prot_ids -output-dir ./output/ -work-area tmp/work/  -diamond-executable ${diamond_bin}
rm -rf tmp
