#!/usr/bin/env bash
# generate_jobs sorted_aligns.asn -minimum-abut-margin 20 -separate-within-introns -output chains -output-slices chains_slices -output-evidence evidence -output-evidence-slices evidence_slices
submit_chainer -minimum-abut-margin 20 -separate-within-introns -asn sorted_aligns.asn -o jobs
total_lines=$(wc -l <jobs)
(( lines_per_file = (total_lines + 1 - 1) / 1 ))
echo total_lines=$total_lines, lines_per_file=$lines_per_file
####split -l$lines_per_file jobs job. -da 3
# Use round robin to distribute jobs across nodes more evenly
if [ $total_lines -lt 1 ]; then
    effective_njobs=$total_lines
else
    effective_njobs=1
fi
split -nr/$effective_njobs jobs job. -da 3

# capture process environment
set +u
cd "$NXF_TASK_WORKDIR"
echo lines_per_file=${lines_per_file[@]} > .command.env
