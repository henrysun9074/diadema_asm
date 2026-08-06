#!/usr/bin/env python3
import os
from pathlib import Path

def main():
    files = []
    lines = []
    slice_map = {}
    files = "evidence.1.out.gz.slices".split()
    files.extend("gnomon_wnode.out.slices".split())
    scaffold = None
    for filename in files:
        filename = Path(filename.strip()).name
        input_type = -1
        scaffold = None
        #if filename.startswith("gnomon_wnode"):
        if filename.find("gnomon_wnode.out") >= 0:
            input_type = 0
        elif filename.find("evidence") >= 0:
            input_type = 1
        else:
            continue
        with open(filename, 'r') as file:
            lines = file.readlines()
        if len(lines) == 0:
            raise Exception(f'Error: file {filename} is empty')
        filename = lines[0].strip()
        filename = Path(filename).name
        for line in lines[1:]:
            separator = line.find('\t')
            pos = int(line[separator+1:])
            if scaffold is not None:  # prior row
                slice_map[scaffold][input_type][1] = pos-1
            scaffold = line[:separator]
            if scaffold not in slice_map.keys():
                slice_map[scaffold] = {0:[0,0], 1:[0,0]}
            slice_map[scaffold][input_type][0] = pos

        filesize = os.path.getsize(filename)
        slice_map[scaffold][input_type][1] = filesize-1
    pairs = []
    for scaffold, values in slice_map.items():
        def get_length(a,b):
            if a == b and a == 0:
                return 0
            else:
                return (b - a)+1
        pairs.append([scaffold, get_length(values[0][0], values[0][1]) + get_length(values[1][0], values[1][1]), values])
    pairs.sort(key = lambda x : x[1], reverse = True)
    with open('scaffold.list', 'w') as file:
        for pair in pairs:
            ##file.write(pair[0]+'\t'+str(pair[1])+'\t'+str(pair[2])+'\n')
            file.write(pair[0]+'\n')

if __name__=="__main__":
    main()
