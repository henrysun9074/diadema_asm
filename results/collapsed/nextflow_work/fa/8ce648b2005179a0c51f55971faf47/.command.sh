#!/usr/bin/env bash -exuo pipefail
mkdir -p tmp
lds2=tmp/indexed_lds
if [ -n "softmask/default_softmask_asnb.asnb" ]; then
    lds2_indexer -source softmask -db tmp/softmask_lds2
    lds2+=",tmp/softmask_lds2"
fi    

filename=$(basename -- "job.000")
extension="${filename##*.}"
(( start_job_id = ((10#$extension) * 2051) + 1 ))

# make the local LDS of the genomic fasta
lds2_indexer -source indexed -db tmp/indexed_lds

# When running multiple jobs on the cluster there is a chance that
# several jobs will run on the same node and thus generate files
# with the same filename. We need to avoid that to be able to stage
# the output files for gpx_make_outputs. We add the job file numeric
# extension as a prefix to the filename.
mkdir -p tmp/interim
annot_wnode -margin 1000 -mincont 1000 -minlen 225 -mpp 10.0 -ncsp 25 -window 200000 -nonconsens -open -nogenbank -lds2 $lds2  -start-job-id $start_job_id -workers 8 -input-jobs job.000 -param 105358.params -O tmp/interim || true
mkdir -p output
cat tmp/interim/* > output/annot_wnode.1.gpx-job.asnb
rm -rf tmp
