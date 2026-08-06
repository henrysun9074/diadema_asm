#!/usr/bin/env bash -exuo pipefail
set -euo pipefail

# Initialize variables to handle unbound variable checking
parameters="--runThreadN 8"
out_dir="DO2_hap1.index"
genome_file="DO2_hap1.fasta"

# Parameter validation for security
if printf '%s' "${parameters}" | grep -q '[;`|&$()<>]'; then
    echo "ERROR: Invalid characters detected in parameters" >&2
    exit 2
fi

# Validate parameters length
if [[ ${#parameters} -gt 1000 ]]; then
    echo "ERROR: Parameter string too long" >&2
    exit 2
fi

mkdir -p "${out_dir}"
echo "INFO: Processing genome file ${genome_file}, output directory ${out_dir}"

# Check that --genomeSAindexNbases is not set
if [[ ! "${parameters}" =~ --genomeSAindexNbases ]]; then
    # Formula from https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf, section 2.2.5
    if ! sa_index_bases=$(python3 -c "import os;import math;print(math.floor(min(14, math.log2(os.path.getsize('${genome_file}'))/2 - 1)))"); then
        echo "ERROR: Failed to calculate genomeSAindexNbases" >&2
        exit 1
    fi

    # Validate calculated value is numeric
    if ! [[ "${sa_index_bases}" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Invalid genomeSAindexNbases value calculated: ${sa_index_bases}" >&2
        exit 1
    fi

    effective_parameters="${parameters} --genomeSAindexNbases ${sa_index_bases}"
else
    effective_parameters="${parameters}"
fi

echo "INFO: STAR index effective parameters: ${effective_parameters}"

# Execute STAR with proper error handling
if ! STAR ${effective_parameters} --runMode genomeGenerate --genomeDir "${out_dir}" --genomeFastaFiles "${genome_file}"; then
    echo "ERROR: STAR genome generation failed" >&2
    exit 1
fi

chmod a+rx "${out_dir}"
echo "INFO: STAR index generation completed successfully"
