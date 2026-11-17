# nist

Measured local `lib/**/*.html`: **9**. Categories: a=2, b=0, c=7.

Source: `metanorma/metanorma-nist` at `40029199d3cf17b32d541de28bb14868335eee03`.

HTML cover includes DOI, series, authors/affiliations, dated lifecycle notices and superseding-publication metadata. Intro includes publication citation/DOI/URL. CSWP Word cover/intro/header variants do not add HTML overrides. Intro needs a metadata partial in addition to TOC layout.

**(b) Theme/config:** Series-specific branding, commerce logo assets and typography belong in config. Withdrawal/status conditions need typed data and parity checks.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/nist/html/header.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/nist/html/header_cswp.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/header_cswp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/nist/html/html_nist_intro.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/html_nist_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/nist/html/html_nist_titlepage.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/html_nist_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/nist/html/scripts.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/nist/html/word_nist_intro.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/word_nist_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/nist/html/word_nist_intro_cswp.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/word_nist_intro_cswp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/nist/html/word_nist_titlepage.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/word_nist_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/nist/html/word_nist_titlepage_cswp.html](https://github.com/metanorma/metanorma-nist/blob/40029199d3cf17b32d541de28bb14868335eee03/lib/isodoc/nist/html/word_nist_titlepage_cswp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
