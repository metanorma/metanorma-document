# iso

Measured local `lib/**/*.html`: **9**. Categories: a=2, b=0, c=7.

Source: `metanorma/metanorma-iso` at `c11202c7656b8367d3047505bfb5f8157151a228`.

HTML has one titlepage and intro. DIS/PRF variants and both header files belong to Word converters, not HTML. Cover includes amendment/corrigendum/extension/supplement titles, stage, committee, ICS and keywords.

**(b) Theme/config:** Alternative human/ISO stylesheet selection, logos, fonts and title labels belong in config. B1 owns copyright destination placement.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/iso/html/header-dis.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/header-dis.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iso/html/header.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iso/html/html_iso_intro.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/html_iso_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/iso/html/html_iso_titlepage.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/html_iso_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/iso/html/word_iso_intro-dis.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/word_iso_intro-dis.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iso/html/word_iso_intro.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/word_iso_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iso/html/word_iso_titlepage-dis.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/word_iso_titlepage-dis.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iso/html/word_iso_titlepage-prf.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/word_iso_titlepage-prf.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/iso/html/word_iso_titlepage.html](https://github.com/metanorma/metanorma-iso/blob/c11202c7656b8367d3047505bfb5f8157151a228/lib/isodoc/iso/html/word_iso_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
