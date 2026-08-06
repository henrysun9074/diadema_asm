#!/usr/bin/env bash -exuo pipefail
ls -1 combine_db_inputs/* > winmask.concat.mft
combine_blast_db -input-manifest winmask.concat.mft -o winmask.asnb
