#!/usr/bin/env bash -exuo pipefail
echo gnomon_wnode.out |tr ' ' '\n' > models.mft
prot_gnomon_prepare  -input-manifest models.mft -olds2 LDS2 -oprot-ids prot_ids.seq_id -onuc-ids nuc_ids.seq_id
