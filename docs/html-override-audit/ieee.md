# ieee

Measured local `lib/**/*.html`: **12**. Categories: a=2, b=0, c=10.

Source: `metanorma/metanorma-ieee` at `b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037`.

Only html_ieee_titlepage.html and html_ieee_intro.html are cover/intro candidates. The larger count includes Word amendment, whitepaper, industry-connection-report and colophon variants. HTML cover uses society/committee, approval dates, ICS and keywords.

**(b) Theme/config:** Times/Source Han/Courier typography and branding are config. Paragraph type stripping and affiliation-table cleanup require separate model-based parity checks (B1/renderer), not copied DOM scripts.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/ieee/html/header.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/header.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/header_amd.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/header_amd.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/header_wp.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/header_wp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/html_ieee_intro.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/html_ieee_intro.html) | (a) | _toc.html.liquid for navigation layout; explicit flavor intro partial for extra metadata. Boilerplate destination IDs require B1 placement/typed content, not DOM moves. |
| [lib/isodoc/ieee/html/html_ieee_titlepage.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/html_ieee_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/ieee/html/scripts.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |
| [lib/isodoc/ieee/html/word_ieee_colophon_wp.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/word_ieee_colophon_wp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/word_ieee_intro.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/word_ieee_intro.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/word_ieee_intro_wp.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/word_ieee_intro_wp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/word_ieee_titlepage.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/word_ieee_titlepage.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/word_ieee_titlepage_icr.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/word_ieee_titlepage_icr.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |
| [lib/isodoc/ieee/html/word_ieee_titlepage_wp.html](https://github.com/metanorma/metanorma-ieee/blob/b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037/lib/isodoc/ieee/html/word_ieee_titlepage_wp.html) | (c) | Word-only cover/intro/colophon or Office header (mso/page fields); not an HTML page header. Outside the HTML port. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
