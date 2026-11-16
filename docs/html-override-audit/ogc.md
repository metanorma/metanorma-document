# ogc

Measured local `lib/**/*.html`: **9**. Categories: a=2, b=0, c=7.

Source: `metanorma/metanorma-ogc` at `92a9133e34b38cb1dca6217795170a4137263298`.

HTML cover includes document subtype, editors/contributors, DOI and publication links; Word whitepaper cover/intro/header variants are separate. Intro conditionally places feedback for Standard / Standard With Suite.

**(b) Theme/config:** Preface order/wrapping/filtering, publisher/logo and fonts are config. License/feedback placement is a B1 dependency.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/ogc/html/header.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ogc/html/header_wp.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/header_wp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ogc/html/html_ogc_intro.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/html_ogc_intro.html) | (a) | _toc.html.liquid for navigation layout; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/ogc/html/html_ogc_titlepage.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/html_ogc_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/ogc/html/scripts.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/ogc/html/word_ogc_intro.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/word_ogc_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ogc/html/word_ogc_intro_wp.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/word_ogc_intro_wp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ogc/html/word_ogc_titlepage.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/word_ogc_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ogc/html/word_ogc_titlepage_wp.html](https://github.com/metanorma/metanorma-ogc/blob/92a9133e34b38cb1dca6217795170a4137263298/lib/isodoc/ogc/html/word_ogc_titlepage_wp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
