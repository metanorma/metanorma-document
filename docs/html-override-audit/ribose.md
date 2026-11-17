# ribose

Measured local `lib/**/*.html`: **5**. Categories: a=2, b=0, c=3.

Source: `metanorma/metanorma-ribose` at `dc142f99acf24e84ad801ff6413267885d81c5de`.

Generic HTML subclass; cover includes publisher/agency and metadata extensions. Intro contains TOC only. SWF, MBx-IF and PDFa tastes inherit this family.

**(b) Theme/config:** Publisher, branding, fonts and metadata-extension configuration belong in theme/taste config.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/ribose/html/header.html](https://github.com/metanorma/metanorma-ribose/blob/dc142f99acf24e84ad801ff6413267885d81c5de/lib/isodoc/ribose/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ribose/html/html_rsd_intro.html](https://github.com/metanorma/metanorma-ribose/blob/dc142f99acf24e84ad801ff6413267885d81c5de/lib/isodoc/ribose/html/html_rsd_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/ribose/html/html_rsd_titlepage.html](https://github.com/metanorma/metanorma-ribose/blob/dc142f99acf24e84ad801ff6413267885d81c5de/lib/isodoc/ribose/html/html_rsd_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/ribose/html/word_rsd_intro.html](https://github.com/metanorma/metanorma-ribose/blob/dc142f99acf24e84ad801ff6413267885d81c5de/lib/isodoc/ribose/html/word_rsd_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ribose/html/word_rsd_titlepage.html](https://github.com/metanorma/metanorma-ribose/blob/dc142f99acf24e84ad801ff6413267885d81c5de/lib/isodoc/ribose/html/word_rsd_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
