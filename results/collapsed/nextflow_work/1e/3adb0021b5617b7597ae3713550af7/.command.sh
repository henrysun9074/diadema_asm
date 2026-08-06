#!/usr/bin/env python3
import os

def main():

    f_quality = open('gnomon_quality_report.txt', 'w')
    f_support = open('gnomon_report.txt', 'w')
    f_support.write('#Gnomon model	Scaffold id	Evidence id	Evidence taxid	Evidence origin	Evidence PIG id	Alignment Percent Identity	Base Coverage Percentage	CDS Base Coverage Percentage	Precise splice-site support	Approximate splice-site support	Core Support	In Minimal Full Introns Support\n')
    f_quality.write('#Gnomon model	Scaffold id	Minimal Full Support	Minimal Same-species Full Support	Minimal Full Intron Support	Minimal Same-species Full Intron Support	Average Base Same-Species Support	Smallest Base Same-Species Support	Average Intron Same-Species Support	Smallest Intron Same-Species Support	Number Introns Same-Species Supported	Ab Initio Percentage	SRS Base Support Percentage	Full intron support SRS count	Partial intron support SRS count	Non-consensus introns	Overlapping strong-signal uORFs	Non-overlapping strong-signal uORFs	SRS Base Support Percentage Unambiguous\n')
    file = None
    with open('reports.txt', 'r') as file:
        for line in file:
            line = line.strip()
            if line == 'QUALITY':
                file = f_quality
                continue
            if line == 'SUPPORT':
                file = f_support
                continue
            if file is None:
                print("file not well formatted")
                exit()
            file.write(line + '\n')

if __name__=="__main__":
    main()
