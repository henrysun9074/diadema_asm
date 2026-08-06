#!/usr/bin/env bash -exuo pipefail
mkdir -p asn
mkdir -p fasta
mkdir -p tmp/interim
cat src/ref_protein.faa > tmp/interim/out.faa
for f in user_src/*; do
    [ -e "$f" ] || continue
    if [[ $f == *.gz ]]; then
        zcat $f >> tmp/interim/out.faa
    else
        cat $f >> tmp/interim/out.faa
    fi
done
seqkit rmdup tmp/interim/out.faa -o fasta/ref_protein.faa
multireader -flags ParseRawID -out-format asn_text -input fasta/ref_protein.faa -output asn/ref_protein.asn -parse-mods
multireader -flags ParseRawID -out-format asn_binary -input fasta/ref_protein.faa -output asn/ref_protein.asnb -parse-mods
rm -rf tmp
