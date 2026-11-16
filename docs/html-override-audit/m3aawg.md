# m3aawg

Measured local `lib/**/*.html`: **6**. Categories: a=2, b=0, c=4.

Source: `metanorma/metanorma-m3aawg` at `141bcc472288d97e3115c310240606b48fbbf519`.

Generic subclass; template filenames still use m3d. Cover includes URL, edition and month/year. Intro also includes title, edition and date, so a TOC replacement alone is insufficient: a flavor intro partial must render that metadata.

**(b) Theme/config:** Publisher/logo/URL identity, typography and date labels are config; typed intro content goes through the flavor renderer hook.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/m3aawg/html/header.html](https://github.com/metanorma/metanorma-m3aawg/blob/141bcc472288d97e3115c310240606b48fbbf519/lib/isodoc/m3aawg/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/m3aawg/html/html_m3d_intro.html](https://github.com/metanorma/metanorma-m3aawg/blob/141bcc472288d97e3115c310240606b48fbbf519/lib/isodoc/m3aawg/html/html_m3d_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/m3aawg/html/html_m3d_titlepage.html](https://github.com/metanorma/metanorma-m3aawg/blob/141bcc472288d97e3115c310240606b48fbbf519/lib/isodoc/m3aawg/html/html_m3d_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/m3aawg/html/scripts.html](https://github.com/metanorma/metanorma-m3aawg/blob/141bcc472288d97e3115c310240606b48fbbf519/lib/isodoc/m3aawg/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/m3aawg/html/word_m3d_intro.html](https://github.com/metanorma/metanorma-m3aawg/blob/141bcc472288d97e3115c310240606b48fbbf519/lib/isodoc/m3aawg/html/word_m3d_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/m3aawg/html/word_m3d_titlepage.html](https://github.com/metanorma/metanorma-m3aawg/blob/141bcc472288d97e3115c310240606b48fbbf519/lib/isodoc/m3aawg/html/word_m3d_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
