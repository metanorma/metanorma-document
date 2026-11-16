# cc

Measured local `lib/**/*.html`: **5**. Categories: a=2, b=0, c=3.

Source: `metanorma/metanorma-cc` at `23eb5bfe21b9f5c5fb1cc8b58d364d5432244dae`.

Titlepage contains author/affiliation, document type and stage. Intro supplies navigation rather than Word headers.

**(b) Theme/config:** Publisher/logo/palette/fonts belong in config; retain the HTML title layout via a template.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/cc/html/header.html](https://github.com/metanorma/metanorma-cc/blob/23eb5bfe21b9f5c5fb1cc8b58d364d5432244dae/lib/isodoc/cc/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/cc/html/html_cc_intro.html](https://github.com/metanorma/metanorma-cc/blob/23eb5bfe21b9f5c5fb1cc8b58d364d5432244dae/lib/isodoc/cc/html/html_cc_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/cc/html/html_cc_titlepage.html](https://github.com/metanorma/metanorma-cc/blob/23eb5bfe21b9f5c5fb1cc8b58d364d5432244dae/lib/isodoc/cc/html/html_cc_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/cc/html/word_cc_intro.html](https://github.com/metanorma/metanorma-cc/blob/23eb5bfe21b9f5c5fb1cc8b58d364d5432244dae/lib/isodoc/cc/html/word_cc_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/cc/html/word_cc_titlepage.html](https://github.com/metanorma/metanorma-cc/blob/23eb5bfe21b9f5c5fb1cc8b58d364d5432244dae/lib/isodoc/cc/html/word_cc_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
