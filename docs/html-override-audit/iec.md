# iec

Measured local `lib/**/*.html`: **6**. Categories: a=2, b=0, c=4.

Source: `metanorma/metanorma-iec` at `74e017c884f2b6b1811b4dbf8dc055be82176eb2`.

ISO HTML subclass with IEC titlepage and intro. Preserve bilingual title components, stage and secretariat metadata. The locally shipped scripts file is not an additional cover.

**(b) Theme/config:** IEC branding/fonts/publisher and section ordering are config. Copyright relocation is a B1 capability, not a theme edit.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/iec/html/header.html](https://github.com/metanorma/metanorma-iec/blob/74e017c884f2b6b1811b4dbf8dc055be82176eb2/lib/isodoc/iec/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iec/html/html_iec_intro.html](https://github.com/metanorma/metanorma-iec/blob/74e017c884f2b6b1811b4dbf8dc055be82176eb2/lib/isodoc/iec/html/html_iec_intro.html) | (a) | _toc.html.liquid for navigation layout; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/iec/html/html_iec_titlepage.html](https://github.com/metanorma/metanorma-iec/blob/74e017c884f2b6b1811b4dbf8dc055be82176eb2/lib/isodoc/iec/html/html_iec_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/iec/html/scripts.html](https://github.com/metanorma/metanorma-iec/blob/74e017c884f2b6b1811b4dbf8dc055be82176eb2/lib/isodoc/iec/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/iec/html/word_iec_intro.html](https://github.com/metanorma/metanorma-iec/blob/74e017c884f2b6b1811b4dbf8dc055be82176eb2/lib/isodoc/iec/html/word_iec_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iec/html/word_iec_titlepage.html](https://github.com/metanorma/metanorma-iec/blob/74e017c884f2b6b1811b4dbf8dc055be82176eb2/lib/isodoc/iec/html/word_iec_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
