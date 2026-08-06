#!/usr/bin/env bash -exuo pipefail
mkdir -p output
gpx_make_outputs -default-output-name align -slices-for affinity -sort-by job-id -unzip align -input-path input -output output/@.#.out -output-manifest output/@.mft -slices-manifest output/@_slices.mft -num-partitions 1
