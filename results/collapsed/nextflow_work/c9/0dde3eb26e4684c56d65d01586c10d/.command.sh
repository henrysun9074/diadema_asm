#!/usr/bin/env bash -exuo pipefail
gpx_qdump -unzip '*' -input-path inputs -o reports.txt 
touch reports.txt
