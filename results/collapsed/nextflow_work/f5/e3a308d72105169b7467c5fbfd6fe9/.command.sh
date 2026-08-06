#!/usr/bin/env bash -exuo pipefail
ls -1 gpx_inputs/* > gpx_inputs.mft
mkdir -p output
gpx_make_outputs -default-output-name chains -slices-for affinity -sort-by affinity -input-manifest gpx_inputs.mft -output output/@.#.out.gz -output-manifest output/@.mft -slices-manifest output/@_slices.mft -num-partitions 1
