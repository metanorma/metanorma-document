# csa

Measured local `lib/**/*.html`: **5**. Categories: a=2, b=0, c=3.

Source: `metanorma/metanorma-csa` at `0c9a34d37cb9047a6c446ff4b94f9c025f0da075`.

Legacy CSA gem templates remain in this snapshot, while the current taste has another CSA template set. Keep these inventories separate; taste base is generic.

**(b) Theme/config:** CSA publisher, assets and typography belong in taste/theme config; audit taste/csa before routing new output.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/csa/html/header.html](https://github.com/metanorma/metanorma-csa/blob/0c9a34d37cb9047a6c446ff4b94f9c025f0da075/lib/isodoc/csa/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/csa/html/html_csa_intro.html](https://github.com/metanorma/metanorma-csa/blob/0c9a34d37cb9047a6c446ff4b94f9c025f0da075/lib/isodoc/csa/html/html_csa_intro.html) | (a) | _toc.html.liquid for navigation layout; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/csa/html/html_csa_titlepage.html](https://github.com/metanorma/metanorma-csa/blob/0c9a34d37cb9047a6c446ff4b94f9c025f0da075/lib/isodoc/csa/html/html_csa_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/csa/html/word_csa_intro.html](https://github.com/metanorma/metanorma-csa/blob/0c9a34d37cb9047a6c446ff4b94f9c025f0da075/lib/isodoc/csa/html/word_csa_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/csa/html/word_csa_titlepage.html](https://github.com/metanorma/metanorma-csa/blob/0c9a34d37cb9047a6c446ff4b94f9c025f0da075/lib/isodoc/csa/html/word_csa_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
