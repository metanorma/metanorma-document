# bipm

Measured local `lib/**/*.html`: **2**. Categories: a=2, b=0, c=0.

Source: `metanorma/metanorma-bipm` at `38d804b7ab7755acda4cb7b22f2c34057df9d4af`.

Generic HTML subclass with BIPM list-counter behavior; cover metadata includes committee logos, SI aspect and part/annex/appendix provenance.

**(b) Theme/config:** Counters/list style, fonts, committee logo assets and publisher identity belong in theme/config; nested list semantics still need renderer parity checks.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/bipm/html/html_bipm_intro.html](https://github.com/metanorma/metanorma-bipm/blob/38d804b7ab7755acda4cb7b22f2c34057df9d4af/lib/isodoc/bipm/html/html_bipm_intro.html) | (a) | document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/bipm/html/html_bipm_titlepage.html](https://github.com/metanorma/metanorma-bipm/blob/38d804b7ab7755acda4cb7b22f2c34057df9d4af/lib/isodoc/bipm/html/html_bipm_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
