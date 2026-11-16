# un

Measured local `lib/**/*.html`: **8**. Categories: a=3, b=0, c=5.

Source: `metanorma/metanorma-un` at `345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e`.

Two HTML titlepages: the converter selects the plenary variant from meeting/session metadata. Preserve session date/number/item/subitem, submission/document language and footnote references. Intro conditionally includes legal/copyright content for Recommendations.

**(b) Theme/config:** UN branding, date/language labels and fonts belong in config. Flavor renderer/variant resolver selects title layout; B1 owns boilerplate placement.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/un/html/header.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/un/html/html_unece_intro.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/html_unece_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/un/html/html_unece_plenary_titlepage.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/html_unece_plenary_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/un/html/html_unece_titlepage.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/html_unece_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/un/html/scripts.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/un/html/word_unece_intro.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/word_unece_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/un/html/word_unece_plenary_titlepage.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/word_unece_plenary_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/un/html/word_unece_titlepage.html](https://github.com/metanorma/metanorma-un/blob/345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e/lib/isodoc/un/html/word_unece_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
