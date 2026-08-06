#!/usr/bin/env bash -exuo pipefail
ls -1 gpx_inputs/* > gpx_inputs.mft
mkdir -p output
gpx_make_outputs -unzip '*'  -input-manifest gpx_inputs.mft -output output/winmask.concat.#.asnb -output-manifest winmask.concat.mft  -num-partitions 1
