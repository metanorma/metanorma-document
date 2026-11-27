This fixture compares the bundled ISO/IEC themes with default (non-alt)
legacy isodoc HTML, using the real flavor models and renderers.

Install frontend dependencies (`cd frontend && npm ci`), then run:

```
HTML_THEME_PARITY=1 bundle exec rspec spec/metanorma/html/renderer/visual_parity_spec.rb
```

The spec requires Node and Puppeteer's Chromium. `PUPPETEER_MODULE` accepts an
absolute module path for a session-local installation. `HTML_THEME_PARITY_OUTPUT`
saves both HTML outputs and computed-style comparison JSON. Without the opt-in,
the browser examples are reported as pending in the ordinary Ruby suite.

The comparison checks heading tags, text, inline emphasis and computed fonts,
sizes, weights, colours and vertical spacing at 1440×1000. JavaScript and remote
resources are disabled, so this measures declared font stacks with local font
fallbacks. It does not establish glyph, cover, responsive, print or dark-mode
parity, or visual review of other flavors and tastes in issue #114.

The theme is loaded explicitly from this repository's flat YAML file. A flavor
gem can register a higher-priority theme; those overrides need their own parity
checks and fixes in the owning repository.
