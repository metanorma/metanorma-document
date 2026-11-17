# itu

Measured local `lib/**/*.html`: **7**. Categories: a=2, b=0, c=5.

Source: `metanorma/metanorma-itu` at `1c5bf3515d813be7de60e7d8178c7a3648552f63`.

HTML cover branches by doctype and includes sector/bureau/series, meeting data, contacts and amendment/corrigendum/annex titles. Intro conditionally supplies legal/license destinations. Service-publication Word titlepage is outside HTML scope.

**(b) Theme/config:** Sector/bureau branding, typography and labels are config; document-type structure and typed metadata remain template/renderer responsibilities.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/itu/html/header.html](https://github.com/metanorma/metanorma-itu/blob/1c5bf3515d813be7de60e7d8178c7a3648552f63/lib/isodoc/itu/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/itu/html/html_itu_intro.html](https://github.com/metanorma/metanorma-itu/blob/1c5bf3515d813be7de60e7d8178c7a3648552f63/lib/isodoc/itu/html/html_itu_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/itu/html/html_itu_titlepage.html](https://github.com/metanorma/metanorma-itu/blob/1c5bf3515d813be7de60e7d8178c7a3648552f63/lib/isodoc/itu/html/html_itu_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/itu/html/scripts.html](https://github.com/metanorma/metanorma-itu/blob/1c5bf3515d813be7de60e7d8178c7a3648552f63/lib/isodoc/itu/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/itu/html/word_itu_intro.html](https://github.com/metanorma/metanorma-itu/blob/1c5bf3515d813be7de60e7d8178c7a3648552f63/lib/isodoc/itu/html/word_itu_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/itu/html/word_itu_titlepage.html](https://github.com/metanorma/metanorma-itu/blob/1c5bf3515d813be7de60e7d8178c7a3648552f63/lib/isodoc/itu/html/word_itu_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/itu/html/word_itu_titlepage_sp.html](https://github.com/metanorma/metanorma-itu/blob/1c5bf3515d813be7de60e7d8178c7a3648552f63/lib/isodoc/itu/html/word_itu_titlepage_sp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
