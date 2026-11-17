# Legacy HTML override audit

Issue: [metanorma-document#115](https://github.com/metanorma/metanorma-document/issues/115), under [metanorma#692](https://github.com/metanorma/metanorma/issues/692). Snapshot measured 2026-11-16. Reference engine: `metanorma/isodoc` at `033d46c6148594a3649d100a886352c8a0215ab6`.

The issue counts reproduce when counting all tracked `.html` under each flavor's `lib/`. That includes Word templates and Office headers; it is not the count of active HTML cover overrides. GB also contains a pre-IsoDoc converter tree. Tests, generated examples, CSS and Ruby rendering methods are excluded. The taste data tree is inventoried separately.

Every file is classified: (a) Liquid layout/template port, (b) theme/config, or (c) documented non-portable artifact. No complete source HTML file in this snapshot is config-only, so the per-file (b) count is zero. Each flavor page separately identifies config-owned concerns inside the templates. A mapping is a porting plan, not a claim that its legacy metadata assigns or output parity already exist.

Reproduce against checked-out, read-only references:

```sh
python3 docs/html-override-audit/measure.py /path/to/flavors > /tmp/inventory.json
diff -u docs/html-override-audit/inventory.json /tmp/inventory.json
```

Clone each listed source first using `git clone --filter=blob:none https://github.com/metanorma/metanorma-<name>.git /path/to/flavors/metanorma-<name>`. The script fails for missing repositories or unclassified file kinds. `inventory.json` pins each source HEAD, per-file SHA-256, mapping and lexically extracted Liquid output references (which may include loop locals; these are not a model schema). An empty ICC clone is explicit. A changed HEAD requires a new audit even if counts stay equal.

## Measured inventory

| Flavor / source | Local HTML files | (a) | (b) | (c) |
| --- | ---: | ---: | ---: | ---: |
| [bipm](bipm.md) | 2 | 2 | 0 | 0 |
| [bsi](bsi.md) | 2 | 2 | 0 | 0 |
| [cc](cc.md) | 5 | 2 | 0 | 3 |
| [csa](csa.md) | 5 | 2 | 0 | 3 |
| [gb](gb.md) | 13 | 3 | 0 | 10 |
| [generic](generic.md) | 6 | 2 | 0 | 4 |
| [iec](iec.md) | 6 | 2 | 0 | 4 |
| [ieee](ieee.md) | 12 | 2 | 0 | 10 |
| [ietf](ietf.md) | 0 | 0 | 0 | 0 |
| [iho](iho.md) | 5 | 2 | 0 | 3 |
| [iso](iso.md) | 9 | 2 | 0 | 7 |
| [itu](itu.md) | 7 | 2 | 0 | 5 |
| [jis](jis.md) | 3 | 2 | 0 | 1 |
| [m3aawg](m3aawg.md) | 6 | 2 | 0 | 4 |
| [mpfa](mpfa.md) | 6 | 2 | 0 | 4 |
| [nist](nist.md) | 9 | 2 | 0 | 7 |
| [ogc](ogc.md) | 9 | 2 | 0 | 7 |
| [oiml](oiml.md) | 0 | 0 | 0 | 0 |
| [plateau](plateau.md) | 0 | 0 | 0 | 0 |
| [ribose](ribose.md) | 5 | 2 | 0 | 3 |
| [un](un.md) | 8 | 3 | 0 | 5 |
| [icc](icc.md) | 0 | 0 | 0 | 0 |
| [pdfa](pdfa.md) | 0 | 0 | 0 | 0 |
| [mbxif](mbxif.md) | 0 | 0 | 0 | 0 |
| [swf](swf.md) | 0 | 0 | 0 | 0 |
| [mko](mko.md) | 0 | 0 | 0 | 0 |
| [snap](snap.md) | 0 | 0 | 0 | 0 |
| [standoc](standoc.md) | 2 | 1 | 0 | 1 |
| [taste](taste.md) | 8 | 5 | 0 | 3 |

Total: **128** source HTML files across **29** repositories. Taste configs measured: **13**. Counts include zero-template sources and shared standoc defaults; they do not count inherited files again.

## Porting boundaries

Theme/config owns colors, fonts, assets, publisher metadata, section order and labels (B2). B1 owns headless rendering, cover/intro placement and postprocessing. Templates with `boilerplate-*-destination` placeholders depend on B1 replacing DOM relocation with typed content placement. Legacy JS tied to jQuery/TOC/old IDs cannot be copied as renderer hooks. Word `header*.html` files are Office page headers, not the HTML `_header.html.liquid` slot.

The GB legacy tree is explicitly (c) for this migration; it has its own historical GB converter API. Current compliant/noncompliant source variants are inventoried independently. IEEE whitepaper/ICR, ISO DIS/PRF, NIST CSWP and OGC whitepaper Word variants remain outside HTML scope. UN plenary is a genuine HTML variant and stays (a).

This card supplies the [flavor hook mechanism](../flavor-template-hooks.md), not complete ports of all mapped templates, new theme files, or parity sign-off. Flavor packages must adapt missing metadata through lutaml-model objects/Drops, run the epic regression gate, and only then switch engines. IETF/RFC output needs its own parity decision.

Reference call sites: `IsoDoc::Convert#html_doc_path` resolves files relative to the converter library directory; `init_covers` distinguishes HTML cover/intro from Word header/cover/intro and defaults scripts to the shared engine asset. `populate_template` supplies legacy flattened metadata. `html_cover` / `html_intro` inject into title/prefatory sections, and `inject_script` appends legacy scripts. These explain why filename counts alone do not establish active HTML overrides.
