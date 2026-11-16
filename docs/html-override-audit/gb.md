# gb

Measured local `lib/**/*.html`: **13**. Categories: a=3, b=0, c=10.

Source: `metanorma/metanorma-gb` at `d67597aa36da3ffc7a520e3fd351f15f41911d08`.

The raw count includes lib/gbdoc (pre-IsoDoc converters) as well as lib/isodoc/gb. The current HTML converter selects html_compliant_gb_titlepage.html even when the compliant option selects a different stylesheet. The other current titlepage is an alternative source, not another default page. Bilingual titles, ICS/CCS IDs, equivalence, replacement notices and implementation/publication labels need typed adapters.

**(b) Theme/config:** Compliant layout choice, fonts, labels, agency/logo assets and style settings belong in config; conditional multilingual cover structure belongs in the flavor template.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/gbdoc/html/header.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/gbdoc/html/header.html) | (c) | Pre-IsoDoc GB converter tree; counted separately, not a second override for the current IsoDoc::Gb converter. Retain as historical reference. |
| [lib/gbdoc/html/html_gb_intro.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/gbdoc/html/html_gb_intro.html) | (c) | Pre-IsoDoc GB converter tree; counted separately, not a second override for the current IsoDoc::Gb converter. Retain as historical reference. |
| [lib/gbdoc/html/html_gb_titlepage.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/gbdoc/html/html_gb_titlepage.html) | (c) | Pre-IsoDoc GB converter tree; counted separately, not a second override for the current IsoDoc::Gb converter. Retain as historical reference. |
| [lib/gbdoc/html/scripts.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/gbdoc/html/scripts.html) | (c) | Pre-IsoDoc GB converter tree; counted separately, not a second override for the current IsoDoc::Gb converter. Retain as historical reference. |
| [lib/gbdoc/html/word_gb_intro.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/gbdoc/html/word_gb_intro.html) | (c) | Pre-IsoDoc GB converter tree; counted separately, not a second override for the current IsoDoc::Gb converter. Retain as historical reference. |
| [lib/gbdoc/html/word_gb_titlepage.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/gbdoc/html/word_gb_titlepage.html) | (c) | Pre-IsoDoc GB converter tree; counted separately, not a second override for the current IsoDoc::Gb converter. Retain as historical reference. |
| [lib/isodoc/gb/html/header.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/isodoc/gb/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/gb/html/html_compliant_gb_titlepage.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/isodoc/gb/html/html_compliant_gb_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/gb/html/html_gb_intro.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/isodoc/gb/html/html_gb_intro.html) | (a) | _toc.html.liquid for navigation layout; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/gb/html/html_gb_titlepage.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/isodoc/gb/html/html_gb_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/gb/html/scripts.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/isodoc/gb/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/gb/html/word_gb_intro.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/isodoc/gb/html/word_gb_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/gb/html/word_gb_titlepage.html](https://github.com/metanorma/metanorma-gb/blob/d67597aa36da3ffc7a520e3fd351f15f41911d08/lib/isodoc/gb/html/word_gb_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
