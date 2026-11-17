# standoc

Measured local `lib/**/*.html`: **2**. Categories: a=1, b=0, c=1.

Source: `metanorma/metanorma-standoc` at `a381a598ed689aaa3d343be54f5fa59a4c8d4dd2`.

Shared standoc support ships html_titlepage.html and scripts.html under lib/isodoc/html. This is an inherited baseline, not a separate publisher identity.

**(b) Theme/config:** Generic publisher/assets and typography belong in config; shared JavaScript needs frontend reconciliation.

The categories below classify whole source files. Styling inside an (a) file still belongs to (b); metadata availability and B1 placement must be checked before claiming parity.

| Source template | Class | Destination / reason |
| --- | --- | --- |
| [lib/isodoc/html/html_titlepage.html](https://github.com/metanorma/metanorma-standoc/blob/a381a598ed689aaa3d343be54f5fa59a4c8d4dd2/lib/isodoc/html/html_titlepage.html) | (a) | _cover.html.liquid at the StandardRenderer cover call; a flavor-owned renderer may select its own named partial. Adapt metadata to typed model/Drop assigns; B1 owns placement. |
| [lib/isodoc/html/scripts.html](https://github.com/metanorma/metanorma-standoc/blob/a381a598ed689aaa3d343be54f5fa59a4c8d4dd2/lib/isodoc/html/scripts.html) | (c) | Legacy DOM/TOC/sidebar JavaScript; cannot copy into the model-driven renderer. Reconcile behavior with frontend assets and B1 postprocessing; do not execute this file through Liquid. |

See [hook contract](../flavor-template-hooks.md) and [measurement method](README.md). Field references and source hashes are retained in [inventory.json](inventory.json).
