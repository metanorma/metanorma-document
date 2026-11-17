# iho

Measured local `lib/**/*.html`: **5**. Categories: a=2, b=0, c=3.

Source: `metanorma/metanorma-iho` at `a1657ab9d50057419229566f5740e000e8e8852b`.

Generic HTML subclass, configured IHO cover with edition/publication date and logos. Intro contains TOC only.

**(b) Theme/config:** IHO assets, fonts and publisher are config; generic metadata filename selection is not an extra template file.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/iho/html/header.html](https://github.com/metanorma/metanorma-iho/blob/a1657ab9d50057419229566f5740e000e8e8852b/lib/isodoc/iho/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iho/html/html_iho_intro.html](https://github.com/metanorma/metanorma-iho/blob/a1657ab9d50057419229566f5740e000e8e8852b/lib/isodoc/iho/html/html_iho_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/iho/html/html_iho_titlepage.html](https://github.com/metanorma/metanorma-iho/blob/a1657ab9d50057419229566f5740e000e8e8852b/lib/isodoc/iho/html/html_iho_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/iho/html/word_iho_intro.html](https://github.com/metanorma/metanorma-iho/blob/a1657ab9d50057419229566f5740e000e8e8852b/lib/isodoc/iho/html/word_iho_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iho/html/word_iho_titlepage.html](https://github.com/metanorma/metanorma-iho/blob/a1657ab9d50057419229566f5740e000e8e8852b/lib/isodoc/iho/html/word_iho_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
