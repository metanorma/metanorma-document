# jis

Measured local `lib/**/*.html`: **3**. Categories: a=2, b=0, c=1.

Source: `metanorma/metanorma-jis` at `d678bf45d98281cc269a0d1338ca32563252d723`.

ISO HTML subclass with local title/intro and an Office header. Japanese title components, amendment titles and editorial data require typed cover bindings.

**(b) Theme/config:** Fonts, publisher and labels are config; feedback/copyright destination placement belongs to B1.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/jis/html/header.html](https://github.com/metanorma/metanorma-jis/blob/d678bf45d98281cc269a0d1338ca32563252d723/lib/isodoc/jis/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/jis/html/html_jis_intro.html](https://github.com/metanorma/metanorma-jis/blob/d678bf45d98281cc269a0d1338ca32563252d723/lib/isodoc/jis/html/html_jis_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/jis/html/html_jis_titlepage.html](https://github.com/metanorma/metanorma-jis/blob/d678bf45d98281cc269a0d1338ca32563252d723/lib/isodoc/jis/html/html_jis_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
