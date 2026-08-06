#!/usr/bin/env bash -exuo pipefail
###diamond_bin=`which diamond`
#diamond_egap uses GP_HOME to build paths to both some gp apps, and third-party
#GP_HOME needs to be the directory that contains third-party, and the directory that contains bin/<gp apps> 
diamond_bin=${GP_HOME}/third-party/diamond/diamond

mkdir -p tmp/asncache
if [[ -n ${TMPDIR-} ]]; then
    mkdir -p ${TMPDIR} || true
fi
auto_prime_cache.py -cache tmp/asncache/ -i indexed/gnomon_wnode.out -oseq-ids /dev/null -split-sequences
auto_prime_cache.py -cache tmp/asncache/ -i indexed/swissprot.asnb -oseq-ids /dev/null -split-sequences

mkdir -p output
mkdir -p tmp/work

echo  -ofmt seq-align-set -query-fmt seq-ids -subject-fmt seq-ids -output-prefix hits -blastp-args '--sam-query-len --very-sensitive --unal 0 --comp-based-stats 1 --masking 1 --evalue 0.0001'
echo "prot_ids.seq_id" > query.mft
diamond_egap  -ofmt seq-align-set -query-fmt seq-ids -subject-fmt seq-ids -output-prefix hits -blastp-args '--sam-query-len --very-sensitive --unal 0 --comp-based-stats 1 --masking 1 --evalue 0.0001'  -asn-cache tmp/asncache/ -nogenbank -query-manifest query.mft -subject swiss_prot_ids -output-dir ./output/ -work-area tmp/work/  -diamond-executable ${diamond_bin}
rm -rf tmp
