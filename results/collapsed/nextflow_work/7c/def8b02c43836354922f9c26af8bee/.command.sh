#!/usr/bin/env bash -exuo pipefail
echo "Assembly: DO2_collapsed_polished sampleID: SRR29948272 Query: SRR29948272_1.fasta,SRR29948272_2.fasta"
    echo "list.seqids" > seqid_list.mft
    lds2_indexer -source genome
    mkdir -p out
    mkdir -p wrkarea
    if [[ -n ${TMPDIR-} ]]; then
        mkdir -p ${TMPDIR} || true
    fi
    if [[ -n ${TEMP-} ]]; then
        mkdir -p ${TEMP} || true
    fi
    echo "<job query =\"lcl|SRR29948272_1.fasta,SRR29948272_2.fasta\" subject=\"DO2_collapsed_polished.index\"></job>" > jobfile
    star=$(which star-with-filter)
    samtools=$(which samtools)
    fastq=$(which fasterq-dump)
    seqkit=$(which seqkit)
    echo SRR29948272_1.fasta; zstdcat SRR29948272_1.fasta | seqkit stats
echo SRR29948272_2.fasta; zstdcat SRR29948272_2.fasta | seqkit stats

    star_wnode -cpus-per-worker 8 -csi-threshold 0 -max-intron 600000 -preserve-star-logs -star-params "--readFilesCommand zstdcat --alignSJoverhangMin 8 --outFilterMultimapNmax 200 --outFilterMismatchNmax 50 --runThreadN 8 --genomeLoad NoSharedMemory --outSAMtype SAM --outSAMattributes NH HI AS nM NM MD jM jI XS MC --outSAMprimaryFlag AllBestScore --outFilterMultimapScoreRange 50 --seedSearchStartLmax 15 --limitOutSAMoneReadBytes 1000000 --outSJtype None --runRNGseed 777 --outMultimapperOrder Old_2.4 --outSAMorder PairedKeepInputOrder" -input-jobs jobfile -genome-sequences-manifest seqid_list.mft -seqkit-executable $seqkit -fastq-executable $fastq  -samtools-executable $samtools -star-executable $star -output-dir . -work-area wrkarea -O out -lds2 genome/lds2.db

    # re-header BAM, dropping @PG and @CO lines containing non-deterministic elements.
    for bam in *.bam; do
        hdr="$bam".hdr
        samtools view -H "$bam" | grep -vE '^@PG|^@CO' > "$hdr"
        samtools reheader --no-PG "$hdr" "$bam" > "$bam".new  # NB: couldn't get --in-place to work
        rm -f "$hdr"
        mv "$bam".new "$bam"

        # recreate index
        [[ -f "${bam}.bai" ]] && samtools index -@ 4 -b "$bam"
        [[ -f "${bam}.csi" ]] && samtools index -@ 4 -c "$bam"
    done
