# Tastes

Source: `metanorma/metanorma-taste` at `36b7e017ed780dc62002a1cbbc17a7b9e8a12b99`. Measured `data/**/*.html`: **8**. Measured taste configs: **13**. These are separate from the engine-local counts.

Taste template directories prepend the base flavor directories via `super`; organization theme templates retain first priority. Logo, font, palette, publisher, i18n and inherited attribute settings map to (b). Cover layouts map to (a). Existing Liquid references such as `bibdata` are not proof that the new typed model exposes an identical Drop schema.

## csa

Base flavor: `generic`. Local HTML files: **5**. Config: [`data/csa/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/csa/config.yaml).

- [`data/csa/header.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/csa/header.html): (c) Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port.
- [`data/csa/html_csa_intro.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/csa/html_csa_intro.html): (a) document.html.liquid for the intro/navigation container; _toc.html.liquid for TOC entries only; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves.
- [`data/csa/html_csa_titlepage.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/csa/html_csa_titlepage.html): (a) _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement.
- [`data/csa/word_csa_intro.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/csa/word_csa_intro.html): (c) Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port.
- [`data/csa/word_csa_titlepage.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/csa/word_csa_titlepage.html): (c) Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port.

## dsa

Base flavor: `iso`. Local HTML files: **0**. Config: [`data/dsa/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/dsa/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## elf

Base flavor: `iso`. Local HTML files: **0**. Config: [`data/elf/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/elf/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## enosema

Base flavor: `iso`. Local HTML files: **0**. Config: [`data/enosema/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/enosema/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## iala

Base flavor: `iho`. Local HTML files: **1**. Config: [`data/iala/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/iala/config.yaml).

- [`data/iala/html_iala_titlepage.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/iala/html_iala_titlepage.html): (a) _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement.

## icc

Base flavor: `iso`. Local HTML files: **1**. Config: [`data/icc/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/icc/config.yaml).

- [`data/icc/htmlcoverpage.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/icc/htmlcoverpage.html): (a) _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement.

## jcgm

Base flavor: `iso`. Local HTML files: **0**. Config: [`data/jcgm/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/jcgm/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## mbxif

Base flavor: `ribose`. Local HTML files: **0**. Config: [`data/mbxif/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/mbxif/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## oiml-cs

Base taste: `oiml`. Local HTML files: **0**. Config: [`data/oiml-cs/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/oiml-cs/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## oiml

Base flavor: `iso`. Local HTML files: **0**. Config: [`data/oiml/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/oiml/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## pdfa

Base flavor: `ribose`. Local HTML files: **1**. Config: [`data/pdfa/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/pdfa/config.yaml).

- [`data/pdfa/htmlcoverpage.html`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/pdfa/htmlcoverpage.html): (a) _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement.

## swf

Base flavor: `ribose`. Local HTML files: **0**. Config: [`data/swf/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/swf/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

## wmo

Base flavor: `iho`. Local HTML files: **0**. Config: [`data/wmo/config.yaml`](https://github.com/metanorma/metanorma-taste/blob/36b7e017ed780dc62002a1cbbc17a7b9e8a12b99/data/wmo/config.yaml).

(b) Configuration and inherited templates; no local HTML file to port.

PDFa additionally uses inner-cover and cover-image metadata; ICC uses copublisher logos; IALA carries its own IHO-derived identity layout. CSA repeats the older gem layout in the taste layer. These require typed bindings and the B1 cover capability before parity sign-off.
