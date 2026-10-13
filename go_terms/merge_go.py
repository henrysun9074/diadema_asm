#!/usr/bin/env python3
"""
Merge GO annotations from eggNOG-mapper and InterProScan into one gene-level
annotation set for enrichment analysis (topGO / clusterProfiler / GOseq).

Usage:
  python merge_go.py \
      --emapper emapper_out/diadema.emapper.annotations \
      --ips     ips_out/dant_prot.faa.tsv \
      --obo     go-basic.obo \
      --pannzer anno.out \
      --ortho   diadema_spur_go.tsv \
      --map     prot2gene.tsv \
      --out     diadema_go

Inputs
  --emapper  eggNOG-mapper *.emapper.annotations file (uses the GOs column)
  --ips      InterProScan TSV output (GO terms are pulled from the GO column)
  --obo      (optional, recommended) go-basic.obo from
             https://purl.obolibrary.org/obo/go/go-basic.obo
             Used to: drop obsolete terms, convert alternate IDs to primary IDs,
             add the ontology (BP/MF/CC), and propagate terms to ancestors.
  --pannzer  (optional) PANNZER2 anno.out file. GO rows (BP/MF/CC_ARGOT) are kept
             when their PPV is >= --pannzer-ppv (default 0.5).
  --ortho    (optional) output of transfer_go.py: id <tab> GO:1,GO:2,...
             (GO terms transferred from S. purpuratus orthologs)
  --map      (optional) 2-column TSV: protein_id <tab> gene_id. Use this when
             your FASTA has one entry per transcript/isoform but your RNA-seq
             counts are per gene. Proteins not in the map keep their own ID.
  --out      output prefix

Outputs
  <out>.gene2go.tsv    long table: gene, GO, ontology, sources (e.g. eggnog;interpro;spur_ortholog)
                       and n_sources (handy for filtering to terms with >=2 lines of support)
  <out>.topgo.map      gene <tab> GO:1, GO:2, ...  (direct terms; topGO propagates itself)
  <out>.term2gene.tsv  GO <tab> gene for clusterProfiler::enricher(TERM2GENE=...).
                       Ancestor-propagated when --obo is given, because enricher()
                       does not walk the GO graph itself.
"""
import argparse
import re
import sys
from collections import defaultdict

GO_RE = re.compile(r"GO:\d{7}")
NS_SHORT = {"biological_process": "BP", "molecular_function": "MF",
            "cellular_component": "CC"}


def read_map(path):
    m = {}
    with open(path) as fh:
        for line in fh:
            if not line.strip() or line.startswith("#"):
                continue
            p, g = line.rstrip("\n").split("\t")[:2]
            m[p] = g
    return m


def parse_emapper(path):
    """Return {protein: set(GO)} from the GOs column."""
    out = defaultdict(set)
    go_col = None
    with open(path) as fh:
        for line in fh:
            if line.startswith("##"):
                continue
            cols = line.rstrip("\n").split("\t")
            if line.startswith("#query"):
                go_col = cols.index("GOs")
                continue
            if go_col is None:
                sys.exit("Could not find the '#query' header line in the emapper file.")
            if len(cols) > go_col and cols[go_col] not in ("-", ""):
                out[cols[0]].update(GO_RE.findall(cols[go_col]))
    return out


def parse_ips(path):
    """Return {protein: set(GO)}. GO terms sit in column 14 of the TSV; they may
    carry source tags such as GO:0005515(InterPro), so IDs are pulled by regex."""
    out = defaultdict(set)
    with open(path) as fh:
        for line in fh:
            if not line.strip() or line.startswith("#"):
                continue
            cols = line.rstrip("\n").split("\t")
            gos = GO_RE.findall("\t".join(cols[11:]))  # InterPro/GO/pathway columns only
            if gos:
                out[cols[0]].update(gos)
    return out


def parse_pannzer(path, min_ppv):
    """Return {protein: set(GO)} from PANNZER2 anno.out.
    Columns: qpid, type, score, PPV, id, desc. GO ids are bare 7-digit numbers."""
    out = defaultdict(set)
    with open(path) as fh:
        for line in fh:
            cols = line.rstrip("\n").split("\t")
            if len(cols) < 5 or cols[1] not in ("BP_ARGOT", "MF_ARGOT", "CC_ARGOT"):
                continue
            try:
                ppv = float(cols[3])
            except ValueError:
                continue
            if ppv >= min_ppv:
                out[cols[0]].add("GO:" + cols[4].strip().zfill(7))
    return out


def parse_ortho(path):
    """Return {id: set(GO)} from transfer_go.py output."""
    out = defaultdict(set)
    with open(path) as fh:
        for line in fh:
            if line.strip() and not line.startswith("#"):
                cols = line.rstrip("\n").split("\t")
                if len(cols) > 1:
                    out[cols[0]].update(GO_RE.findall(cols[1]))
    return out


def parse_obo(path):
    """Minimal go-basic.obo parser: parents (is_a + part_of), namespace,
    obsolete flags and alt_id -> primary id."""
    parents, ns, obsolete, alt = defaultdict(set), {}, set(), {}
    cur = None
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if line == "[Term]":
                cur = {}
                continue
            if line.startswith("[") and line.endswith("]"):
                cur = None
                continue
            if cur is None or not line:
                continue
            key, _, val = line.partition(": ")
            if key == "id":
                cur["id"] = val
            elif key == "namespace":
                ns[cur["id"]] = NS_SHORT.get(val, val)
            elif key == "is_obsolete" and val == "true":
                obsolete.add(cur["id"])
            elif key == "alt_id":
                alt[val] = cur["id"]
            elif key == "is_a":
                parents[cur["id"]].add(val.split()[0])
            elif key == "relationship" and val.startswith("part_of "):
                parents[cur["id"]].add(val.split()[1])
    return parents, ns, obsolete, alt


def ancestors(term, parents, cache):
    if term in cache:
        return cache[term]
    result = set()
    for p in parents.get(term, ()):
        result.add(p)
        result |= ancestors(p, parents, cache)
    cache[term] = result
    return result


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--emapper", required=True)
    ap.add_argument("--ips", required=True)
    ap.add_argument("--obo")
    ap.add_argument("--pannzer")
    ap.add_argument("--pannzer-ppv", type=float, default=0.5)
    ap.add_argument("--ortho")
    ap.add_argument("--map")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    sys.setrecursionlimit(10000)
    pmap = read_map(a.map) if a.map else {}

    # gene -> GO -> set of sources
    ann = defaultdict(lambda: defaultdict(set))
    inputs = [("eggnog", parse_emapper(a.emapper)), ("interpro", parse_ips(a.ips))]
    if a.pannzer:
        inputs.append(("pannzer", parse_pannzer(a.pannzer, a.pannzer_ppv)))
    if a.ortho:
        inputs.append(("spur_ortholog", parse_ortho(a.ortho)))
    for source, parsed in inputs:
        for prot, gos in parsed.items():
            gene = pmap.get(prot, prot)
            for go in gos:
                ann[gene][go].add(source)

    ns, n_obsolete, n_alt = {}, 0, 0
    parents = None
    if a.obo:
        parents, ns, obsolete, alt = parse_obo(a.obo)
        cleaned = defaultdict(lambda: defaultdict(set))
        for gene, gos in ann.items():
            for go, src in gos.items():
                if go in alt:
                    n_alt += 1
                    go = alt[go]
                if go in obsolete:
                    n_obsolete += 1
                    continue
                cleaned[gene][go] |= src
        ann = cleaned

    # direct annotations
    with open(f"{a.out}.gene2go.tsv", "w") as long_fh, \
         open(f"{a.out}.topgo.map", "w") as topgo_fh:
        long_fh.write("gene\tGO\tontology\tsources\tn_sources\n")
        for gene in sorted(ann):
            gos = sorted(ann[gene])
            if not gos:
                continue
            for go in gos:
                src = ann[gene][go]
                long_fh.write(f"{gene}\t{go}\t{ns.get(go, 'NA')}\t"
                              f"{';'.join(sorted(src))}\t{len(src)}\n")
            topgo_fh.write(f"{gene}\t{', '.join(gos)}\n")

    # TERM2GENE (propagated if we have the ontology)
    cache = {}
    n_pairs = 0
    with open(f"{a.out}.term2gene.tsv", "w") as fh:
        fh.write("GO\tgene\n")
        for gene in sorted(ann):
            terms = set(ann[gene])
            if parents is not None:
                for go in list(terms):
                    terms |= ancestors(go, parents, cache)
                # drop the three root terms; they are uninformative for enrichment
                terms -= {"GO:0008150", "GO:0003674", "GO:0005575"}
            for go in sorted(terms):
                fh.write(f"{go}\t{gene}\n")
                n_pairs += 1

    # summary
    genes = [g for g in ann if ann[g]]
    by_src = defaultdict(int)
    for g in genes:
        for s in set().union(*ann[g].values()):
            by_src[s] += 1
    print(f"Genes with >=1 GO term: {len(genes)}")
    for name, _ in inputs:
        print(f"  with terms from {name:<14}: {by_src[name]}")
    print(f"Direct gene-GO pairs: {sum(len(ann[g]) for g in genes)}")
    if a.obo:
        print(f"Alt IDs remapped: {n_alt}; obsolete terms dropped: {n_obsolete}")
        print(f"Propagated TERM2GENE pairs: {n_pairs}")
    else:
        print("No --obo given: TERM2GENE is NOT propagated and obsolete terms were not removed.")
    print(f"Wrote {a.out}.gene2go.tsv, {a.out}.topgo.map, {a.out}.term2gene.tsv")


if __name__ == "__main__":
    main()