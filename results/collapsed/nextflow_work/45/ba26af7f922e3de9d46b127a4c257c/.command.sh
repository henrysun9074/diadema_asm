#!/usr/bin/env bash -exuo pipefail
mkdir -p asn
mkdir -p fasta
mkdir -p tmp/interim
zcat src/7586.proteins.faa.gz | seqkit grep -r -n -p "\[(Antedon mediterranea)|(Apostichopus japonicus)|(Lytechinus pictus)|(Diadema antillarum)|(Patiria miniata)|(Asterias rubens)\]" | sed 's/>\([^ |]\+\)\( .*\)\?$/>lcl\|\1\2/' > tmp/interim/out.faa
for f in user_src/*; do
    [ -e "$f" ] || continue
    if [[ $f == *.gz ]]; then
        zcat $f >> tmp/interim/out.faa
    else
        cat $f >> tmp/interim/out.faa
    fi
done
seqkit rmdup tmp/interim/out.faa -o fasta/7586.proteins.faa
multireader -flags ParseRawID -out-format asn_text -input fasta/7586.proteins.faa -output asn/7586.proteins.asn -parse-mods
multireader -flags ParseRawID -out-format asn_binary -input fasta/7586.proteins.faa -output asn/7586.proteins.asnb -parse-mods
rm -rf tmp
