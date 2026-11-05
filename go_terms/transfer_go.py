#!/usr/bin/env python3
"""
Transfer GO terms from Spur to Dant via DIAMOND reciprocal best hits (RBH) at the gene level

Inputs
  --go        Echinobase GeneGoTerms.txt
  --spur-map  Echinobase NcbiProteinEchinobaseGene_Spur.txt
  --fwd       DIAMOND outfmt-6 of Diadema (query) vs Spur (db)
  --rev       DIAMOND outfmt-6 of Spur (query) vs Diadema (db)
  --map       (optional) Diadema protein_id file
  --out       output file
"""
import argparse
import re
import sys
from collections import defaultdict

VERSION_RE = re.compile(r"\.\d+$")


def strip_version(acc):
    return VERSION_RE.sub("", acc)


def read_two_col(path):
    m = {}
    with open(path) as fh:
        for line in fh:
            if line.strip() and not line.startswith("#"):
                a, b = line.rstrip("\n").split("\t")[:2]
                m[a] = b
    return m


def load_spur(go_path, map_path):
    prot2gene, gene2sym = {}, {}
    with open(map_path) as fh:
        for line in fh:
            cols = line.rstrip("\n").split("\t")
            if len(cols) >= 3:
                prot2gene[strip_version(cols[1])] = cols[2]
                if len(cols) >= 4:
                    gene2sym[cols[2]] = cols[3]
    spur_genes = set(prot2gene.values())
    gene2go = {}
    with open(go_path) as fh:
        for line in fh:
            cols = line.rstrip("\n").split("\t")
            # GeneGoTerms.txt covers several echinoderms; keep S. purpuratus genes only
            if len(cols) >= 4 and cols[1] in spur_genes:
                gos = [g for g in cols[3].split(",") if g.startswith("GO:")]
                if gos:
                    gene2go[cols[1]] = gos
                    gene2sym.setdefault(cols[1], cols[2])
    return prot2gene, gene2go, gene2sym


def best_hits(path, qkey, skey, a):
    """Best hit per query gene after filtering"""
    best = {}
    with open(path) as fh:
        for line in fh:
            q, s, pid, length, qlen, slen, ev, bits = line.rstrip("\n").split("\t")[:8]
            pid, length, qlen, slen = float(pid), float(length), float(qlen), float(slen)
            ev, bits = float(ev), float(bits)
            if ev > a.evalue or pid < a.pident:
                continue
            if 100 * length / qlen < a.cov or 100 * length / slen < a.cov:
                continue
            qg, sg = qkey(q), skey(s)
            if qg is None or sg is None:
                continue
            if qg not in best or bits > best[qg][1]:
                best[qg] = (sg, bits)
    return {q: s for q, (s, _) in best.items()}


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--go", required=True)
    ap.add_argument("--spur-map", required=True)
    ap.add_argument("--fwd", required=True)
    ap.add_argument("--rev", required=True)
    ap.add_argument("--map")
    ap.add_argument("--out", required=True)
    ap.add_argument("--evalue", type=float, default=1e-10)
    ap.add_argument("--pident", type=float, default=30.0)
    ap.add_argument("--cov", type=float, default=50.0)
    a = ap.parse_args()

    sp_prot2gene, sp_gene2go, sp_gene2sym = load_spur(a.go, a.spur_map)
    if not sp_prot2gene:
        sys.exit("No S. purpuratus proteins read from --spur-map.")
    dmap = read_two_col(a.map) if a.map else {}

    def d_gene(x):
        return dmap.get(x, x)

    def s_gene(x):
        return sp_prot2gene.get(strip_version(x))

    fwd = best_hits(a.fwd, d_gene, s_gene, a)   # Diadema gene -> Spur gene
    rev = best_hits(a.rev, s_gene, d_gene, a)   # Spur gene -> Diadema gene

    n_rbh = n_go = 0
    with open(a.out, "w") as out:
        for dg, sg in sorted(fwd.items()):
            if rev.get(sg) != dg:
                continue
            n_rbh += 1
            gos = sp_gene2go.get(sg)
            if gos:
                n_go += 1
                out.write(f"{dg}\t{','.join(sorted(set(gos)))}\t{sg}\t{sp_gene2sym.get(sg, '')}\n")

    unmapped = sum(1 for line in open(a.rev) if s_gene(line.split("\t", 1)[0]) is None)
    print(f"S. purpuratus genes with GO terms: {len(sp_gene2go)}")
    print(f"Diadema genes with a filtered best hit: {len(fwd)}")
    print(f"Reciprocal best hits (1:1): {n_rbh}")
    print(f"RBH genes receiving GO terms: {n_go}")
    if unmapped:
        print(f"Warning: {unmapped} lines in --rev had S. purpuratus IDs not found in "
              f"--spur-map (check FASTA headers vs. accessions).")

if __name__ == "__main__":
    main()