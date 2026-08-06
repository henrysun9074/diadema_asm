#!/usr/bin/env bash -exuo pipefail
mkdir -p output
if [ -s accept.ftable_annot ]; then
    annotwriter -i accept.ftable_annot -nogenbank -format gff3 -o output/accept.gff
else
    touch output/accept.gff
fi
