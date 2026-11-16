# generic

Measured local `lib/**/*.html`: **6**. Categories: a=2, b=0, c=4.

Source: `metanorma/metanorma-generic` at `cb41786ff4feb4b730a1154a6ff82f2171dbe064`.

Baseline configurable HTML converter. Titlepage includes agency/security/publisher metadata and intro has a Contents heading. Generic configuration can redirect filenames; measured files are the shipped defaults.

**(b) Theme/config:** Config controls publisher, fonts, logos and stylesheet options. Do not encode these values in new renderer subclasses.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/generic/html/header.html](https://github.com/metanorma/metanorma-generic/blob/cb41786ff4feb4b730a1154a6ff82f2171dbe064/lib/isodoc/generic/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/generic/html/html_generic_intro.html](https://github.com/metanorma/metanorma-generic/blob/cb41786ff4feb4b730a1154a6ff82f2171dbe064/lib/isodoc/generic/html/html_generic_intro.html) | (a) | _toc.html.liquid for navigation layout; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/generic/html/html_generic_titlepage.html](https://github.com/metanorma/metanorma-generic/blob/cb41786ff4feb4b730a1154a6ff82f2171dbe064/lib/isodoc/generic/html/html_generic_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/generic/html/scripts.html](https://github.com/metanorma/metanorma-generic/blob/cb41786ff4feb4b730a1154a6ff82f2171dbe064/lib/isodoc/generic/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/generic/html/word_generic_intro.html](https://github.com/metanorma/metanorma-generic/blob/cb41786ff4feb4b730a1154a6ff82f2171dbe064/lib/isodoc/generic/html/word_generic_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/generic/html/word_generic_titlepage.html](https://github.com/metanorma/metanorma-generic/blob/cb41786ff4feb4b730a1154a6ff82f2171dbe064/lib/isodoc/generic/html/word_generic_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
