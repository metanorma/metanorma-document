#!/usr/bin/env python3
"""Read-only inventory of checked-out flavor lib/*.html and taste data/*.html.

Writes JSON to stdout. Clones must already exist; missing inputs are errors.
No fixtures, generated examples, CSS, or Word/HTML Ruby methods are counted.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

FLAVORS = "bipm bsi cc csa gb generic iec ieee ietf iho iso itu jis m3aawg mpfa nist ogc oiml plateau ribose un icc pdfa mbxif swf mko snap standoc".split()


def git(repo, *args):
    return subprocess.check_output(["git", "-C", str(repo), *args], text=True).strip()


def mapping(path):
    name = path.name
    if "gbdoc" in path.parts:
        return "c", "Pre-IsoDoc GB converter tree; counted separately, not a second override for the current IsoDoc::Gb converter. Retain as historical reference."
    if name.startswith("word_") or name.startswith("header"):
        return "c", "Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port."
    if name == "scripts.html":
        return "c", "Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid."
    if "intro" in name:
        return "a", "_toc.html.liquid for navigation layout; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves."
    if name.startswith("html"):
        return "a", "_cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement."
    raise ValueError(f"Unclassified template: {path}")


def inventory(root):
    rows = []
    for flavor in FLAVORS + ["taste"]:
        repo = root / f"metanorma-{flavor}"
        if not (repo / ".git").exists():
            raise FileNotFoundError(repo)
        head = subprocess.run(["git", "-C", str(repo), "rev-parse", "--verify",
                               "--quiet", "HEAD"], capture_output=True, text=True)
        if head.returncode not in (0, 1):
            raise RuntimeError(head.stderr)
        commit = head.stdout.strip() or None
        # Enumerate tracked sources, not files appearing during a concurrent clone.
        paths = git(repo, "ls-files").splitlines()
        files = []
        for name in paths:
            p = Path(name)
            if p.suffix != ".html" or p.parts[0] not in ({"data"} if flavor == "taste" else {"lib"}):
                continue
            source = (repo / p).read_bytes()
            kind, target = mapping(p)
            files.append({"path": name, "sha256": hashlib.sha256(source).hexdigest(),
                          "category": kind, "mapping": target,
                          "fields": sorted(set(re.findall(r"{{-?\s*([a-zA-Z_][\w.]*)", source.decode("utf-8"))))})
        configs = []
        if flavor == "taste":
            for name in paths:
                p = Path(name)
                if p.parts[0] != "data" or p.name != "config.yaml":
                    continue
                source = (repo / p).read_text()
                parent = re.search(r"^base-(flavor|taste):\s*(\S+)", source, re.M)
                configs.append({"path": name, "name": p.parts[1],
                                "parent_kind": parent[1] if parent else None,
                                "parent": parent[2] if parent else None})
        rows.append({"flavor": flavor, "commit": commit, "count": len(files),
                     "categories": {kind: sum(f["category"] == kind for f in files) for kind in "abc"},
                     "files": files, "tastes": configs})
    return rows


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("flavors_root", type=Path)
    print(json.dumps(inventory(parser.parse_args().flavors_root), indent=2))
