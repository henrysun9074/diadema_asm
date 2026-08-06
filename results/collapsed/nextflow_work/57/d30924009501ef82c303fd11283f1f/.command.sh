#!/usr/bin/env bash -exuo pipefail
echo list.seqids | tr ' ' '\n' > scaffolds.mft
for file in chains.1.out.gz.slices; do
    echo $file >> chains_slices.mft
    # remove path from the first line of this file
    sed -i -e '1s/\(.*\)\/\(.*\)$/\2/' $file
done
gpx_qsubmit  -ids-manifest scaffolds.mft -slices-manifest chains_slices.mft -o jobs
total_lines=$(wc -l <jobs)
(( lines_per_file = ($total_lines + 1 - 1) / 1 ))
echo total_lines=$total_lines, lines_per_file=$lines_per_file
# split -l$lines_per_file jobs job. -da 3
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
