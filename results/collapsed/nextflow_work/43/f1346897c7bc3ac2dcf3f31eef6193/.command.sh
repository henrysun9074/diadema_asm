#!/usr/bin/env python3
import os

os.makedirs("output", exist_ok=True)
with open("inputs/input_prots.faa", 'rt') as f:
    items = 0
    chunk = []
    nextfile = 1
    for line in f:
        if line and line[0] == '>':
            items += 1
            if items > 25000:
                with open(f"output/aligns.{nextfile}.faa", "w") as outf:
                    outf.write(''.join(chunk))
                    chunk = []
                    nextfile += 1
                    items = 1
        chunk.append(line)
    if chunk:
        with open(f"output/aligns.{nextfile}.faa", "w") as outf:
            outf.write(''.join(chunk))
