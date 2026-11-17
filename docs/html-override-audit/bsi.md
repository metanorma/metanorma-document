# bsi

Measured local `lib/**/*.html`: **2**. Categories: a=2, b=0, c=0.

Source: `metanorma/metanorma-bsi` at `c267be75f959a253bc82d4b02c13db1bff4a9673`.

ISO HTML subclass; title/part/subtitle variants, author/editorial-group metadata and draft stage need typed cover assigns. Copyright destination in intro is a B1 placement dependency.

**(b) Theme/config:** Gesta/Tahoma font stack, branding and TOC levels belong in config; authority removal and displayorder processing are B1/renderer parity work.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/bsi/html/html_bsi_intro.html](https://github.com/metanorma/metanorma-bsi/blob/c267be75f959a253bc82d4b02c13db1bff4a9673/lib/isodoc/bsi/html/html_bsi_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/bsi/html/html_bsi_titlepage.html](https://github.com/metanorma/metanorma-bsi/blob/c267be75f959a253bc82d4b02c13db1bff4a9673/lib/isodoc/bsi/html/html_bsi_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
