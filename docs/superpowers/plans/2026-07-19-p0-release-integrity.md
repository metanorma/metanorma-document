# P0 Release Integrity + Housekeeping Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the five P0 release-integrity findings from TODO.consolidated.md (gem ships without frontend assets, dead pubid integration, broken rake task loading, broken contributor setup, prerelease deps) plus CI honesty and TODO housekeeping.

**Architecture:** Surgical config/packaging fixes — Gemfile, Rakefile, gemspec, two CI workflows, `html/flavor.rb` + `html/generator.rb` (pubid), `mirror/output/formats/inline_format.rb` (warning). No renderer internals touched. Housekeeping moves fully-done, git-ignored TODO dirs into `TODO.done/`.

**Tech Stack:** Ruby 3.4, bundler, RSpec, rubocop, pubid 2.0.0.pre.alpha, relaton-bib, Vite/npm (frontend).

## Global Constraints

- CLAUDE.md: never Nokogiri on document model XML; `each_mixed_content` for mixed nodes; no regex HTML stripping. (None of these tasks touch rendering content, but the rules still apply.)
- No `git commit`/`git rm`/other git mutations — the user reviews and commits at the end.
- Spec suite config is `c.syntax = :should`; Task 2 enables `:expect` too. New specs use `expect`.
- `pubid` has no stable 2.x on rubygems (latest: 2.0.0.pre.alpha.8) — the prerelease pin stays, documented.
- `.github/workflows/rake.yml` and `release.yml` are Cimas-managed ("do not edit") — new CI goes in NEW workflow files.
- `.gitignore` already ignores `TODO*` (except tracked `TODO.finalize/`), so moves into `TODO.done/` stay ignored.

---

### Task 1: Gemfile — released gems by default, env opt-ins

**Files:**
- Modify: `Gemfile`

**Interfaces:**
- Produces: `bundle install` works on a fresh clone against released gems; `METANORMA_CI_EDGE=1` (github main branches) and `METANORMA_DEV_LOCAL=1` (sibling checkouts) as opt-ins. Later tasks rely on a working `bundle exec`.

- [ ] **Step 1: Rewrite the conditional block (lines 8-18)**

Replace:

```ruby
if ENV["CI"]
  gem "canon", github: "lutaml/canon", branch: "main"
  ...
else
  gem "canon", path: "../../lutaml/canon"
  ...
end
```

with:

```ruby
# Dependency sources. Default (no env vars): released gems, exactly the
# contract downstream users get — CI and local dev must test that.
# METANORMA_CI_EDGE=1  -> track upstream main branches (bleeding-edge CI).
# METANORMA_DEV_LOCAL=1 -> sibling checkouts on the author's machine.
if ENV["METANORMA_CI_EDGE"]
  gem "canon", github: "lutaml/canon", branch: "main"
  gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
  gem "mml", github: "plurimath/mml", branch: "main"
  gem "moxml", github: "lutaml/moxml", branch: "main"
elsif ENV["METANORMA_DEV_LOCAL"]
  gem "canon", path: "../../lutaml/canon"
  gem "lutaml-model", path: "../../lutaml/lutaml-model"
  gem "mml", path: "../../plurimath/mml"
end
```

(Note: the old `pubid` local path is dropped — `../../mn/pubid` no longer exists, which is what broke `bundle install`.)

- [ ] **Step 2: Install and baseline**

Run: `bundle install`
Expected: resolves pubid 2.0.0.pre.alpha.x, relaton-bib 2.2.0.pre.alpha.1, lutaml-model 0.8.x — success.

Run: `bundle exec rspec`
Expected: record pass/fail count as the baseline for every later task. If failures appear that trace to released-vs-HEAD dependency gaps, note them in TODO.consolidated.md (that is the released-contract gap made visible, not a regression from this task).

- [ ] **Step 3: Verify pubid constants for Task 5**

Run: `bundle exec ruby -e 'require "pubid"; %w[Iso Iec Ieee Iho Itu Oiml].each { |m| puts "#{m}: #{defined?(Pubid.const_get(m)) ? "ok" : "MISSING"}" }'`
Expected: list of which modules exist. Any MISSING module loses its `pubid_module:` entry in Task 5.

### Task 2: spec_helper — enable expect syntax alongside should

**Files:**
- Modify: `spec/spec_helper.rb:12`

**Interfaces:**
- Produces: `expect()` usable in new specs (Tasks 5, 6).

- [ ] **Step 1: Change `c.syntax = :should` to `c.syntax = %i[should expect]`**

- [ ] **Step 2: Verify**

Run: `bundle exec rspec spec/metanorma/html/flavor_registry_spec.rb`
Expected: same result as baseline (no behavior change).

### Task 3: Rakefile — load tasks/ and guard frontend packaging

**Files:**
- Modify: `Rakefile`

- [ ] **Step 1: Fix the tasks glob (line 13)**

Replace `Dir.glob("lib/tasks/*.rake").each { |task| load task }` with:

```ruby
Dir.glob(File.join(__dir__, "tasks", "*.rake")).each { |task| load task }
```

- [ ] **Step 2: Replace the release-only frontend hook (lines 23-24) with a build hook + guard**

Replace `Rake::Task["release"].enhance(["build_frontend"]) if Rake::Task.task_defined?("release")` with:

```ruby
# Abort packaging if the SPA bundle is missing — the gem must never
# ship without frontend assets (0.3.0 did, silently).
desc "Verify frontend assets exist for packaging"
task :ensure_frontend_dist do
  bundle = File.join(__dir__, "frontend", "dist", "app.iife.js")
  unless File.exist?(bundle)
    abort("ERROR: #{bundle} is missing; the gem would ship without " \
          "the SPA. Run `rake build_frontend` first.")
  end
end

# bundler's `release` depends on `build`, so enhancing `build` covers both.
if Rake::Task.task_defined?("build")
  Rake::Task["build"].enhance(["build_frontend", "ensure_frontend_dist"])
end
```

- [ ] **Step 3: Verify task loading**

Run: `bundle exec rake -T | grep -E "roundtrip|frontend"`
Expected: `rake roundtrip:site[...]`, `rake roundtrip:file[...]`, `rake roundtrip:consolidate[...]`, `rake build_frontend`, `rake ensure_frontend_dist` all listed.

- [ ] **Step 4: Verify the guard**

Run: `bundle exec rake ensure_frontend_dist`
Expected: exit 0 if `frontend/dist/app.iife.js` exists locally; abort with the ERROR message otherwise. (If missing, run `cd frontend && npm install && npm run build` once — needed for Task 4 verification anyway.)

### Task 4: gemspec hygiene + remove stale lib/data

**Files:**
- Modify: `metanorma-document.gemspec:27-31`
- Delete: `lib/data/` (4 tracked files, 108K stale Vue build, referenced nowhere)

- [ ] **Step 1: Confirm lib/data is unreferenced**

Run: `grep -rn "data/dist\|lib/data" lib spec exe` (expect no matches)
Run: `rm -rf lib/data`

- [ ] **Step 2: Extend the reject list**

Replace the `reject` block with:

```ruby
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/
                          .rubocop.yml .rubocop_todo.yml TODO docs/
                          lib/data/])
    end
```

- [ ] **Step 3: Verify gem contents**

Run: `bundle exec rake build && gem spec pkg/metanorma-document-0.3.0.gem files | ruby -r yaml -e 'f = YAML.safe_load(STDIN.read); puts "total: #{f.size}"; puts "frontend dist: #{f.grep(%r{frontend/dist}).inspect}"; puts "TODO/docs/lib-data leftovers: #{f.grep(%r{^(TODO|docs/|lib/data)}).inspect}"'`
Expected: total > 0; frontend dist includes `frontend/dist/app.iife.js` and `app.css`; leftovers `[]`.

### Task 5: pubid — require the gem, fix Ithu typo, fail loudly

**Files:**
- Create: `spec/metanorma/html/flavor_spec.rb`
- Modify: `lib/metanorma/html/generator.rb:166` (`:"Pubid::Ithu"` → `:"Pubid::Itu"`)
- Modify: `lib/metanorma/html/flavor.rb` (require + loud resolution)

**Interfaces:**
- Consumes: Task 1 Step 3's list of existing `Pubid::*` modules.
- Produces: `Flavor#pubid_module_const` returns the module or raises `ArgumentError` naming the flavor and module; never silently nil for a configured module.

- [ ] **Step 1: Write the failing spec `spec/metanorma/html/flavor_spec.rb`**

```ruby
# frozen_string_literal: true

require "spec_helper"
require "metanorma/html"
require "metanorma/iso_document"
require "metanorma/itu_document"

RSpec.describe Metanorma::Html::Flavor do
  def build_flavor(name:, pubid_module: nil)
    described_class.new(name: name, model_class: Object,
                        renderer_class: Object, pubid_module: pubid_module)
  end

  describe "#pubid_module_const" do
    it "returns nil when no pubid module is configured" do
      expect(build_flavor(name: :cc).pubid_module_const).to be_nil
    end

    it "resolves a configured pubid module" do
      expect(build_flavor(name: :iso, pubid_module: :"Pubid::Iso")
             .pubid_module_const).to eq(Pubid::Iso)
    end

    it "raises ArgumentError naming flavor and module when unresolvable" do
      flavor = build_flavor(name: :itu, pubid_module: :"Pubid::Ithu")
      expect { flavor.pubid_module_const }
        .to raise_error(ArgumentError, /itu.*Pubid::Ithu/)
    end
  end

  describe "Generator flavor registry" do
    it "resolves every configured pubid module" do
      modules = Metanorma::Html::Generator.flavors.map(&:pubid_module).compact
      expect(modules).not_to be_empty
      modules.each { |m| expect(Object.const_get(m.to_s)).to be_a(Module) }
    end
  end
end
```

- [ ] **Step 2: Run spec, expect failure**

Run: `bundle exec rspec spec/metanorma/html/flavor_spec.rb`
Expected: FAIL — `Pubid` uninitialized / resolutions nil (gem never required) and no ArgumentError.

- [ ] **Step 3: Implement**

In `lib/metanorma/html/flavor.rb`, after `# frozen_string_literal: true` add:

```ruby
require "pubid"
```

Replace `#pubid_module_const` with:

```ruby
      def pubid_module_const
        return nil unless pubid_module

        Object.const_get(pubid_module.to_s)
      rescue NameError
        raise ArgumentError,
              "Flavor #{name.inspect}: pubid module #{pubid_module} could " \
              "not be resolved — fix the registration in " \
              "Html::Generator.build_flavor_registry"
      end
```

In `lib/metanorma/html/generator.rb:166` change `:"Pubid::Ithu"` to `:"Pubid::Itu"`.

If Task 1 Step 3 reported any registered module MISSING (e.g. `Pubid::Oiml`), remove that flavor's `pubid_module:` entry entirely (honest config: no module, no parsing) and note it in TODO.consolidated.md.

- [ ] **Step 4: Run spec, expect pass; then check collateral**

Run: `bundle exec rspec spec/metanorma/html/flavor_spec.rb spec/metanorma/html/flavor_registry_spec.rb spec/metanorma/html/generator_spec.rb`
Expected: PASS. If `flavor_registry_spec.rb` asserted nil-resolution behavior anywhere, update those expectations to the new loud behavior.

### Task 6: InlineFormat — warn once when the SPA bundle is missing

**Files:**
- Create: `spec/metanorma/mirror/output/formats/inline_format_missing_bundle_spec.rb`
- Modify: `lib/metanorma/mirror/output/formats/inline_format.rb`

- [ ] **Step 1: Write the failing spec**

```ruby
# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Output::Formats::InlineFormat do
  it "warns on stderr when the IIFE bundle is missing" do
    format = described_class.new(dist_dir: Dir.mktmpdir)
    guide = { "blocks" => [] }
    out = File.join(Dir.mktmpdir, "out.html")

    expect { format.write(out, guide) }.to output(/app\.iife\.js/).to_stderr
    expect(File.exist?(out)).to be true
  end
end
```

(Adjust `guide` shape to whatever `HtmlRenderer.new(guide).render` minimally accepts — check an existing inline_format spec and copy its guide.)

- [ ] **Step 2: Run spec, expect failure**

Run: `bundle exec rspec spec/metanorma/mirror/output/formats/inline_format_missing_bundle_spec.rb`
Expected: FAIL (no warning emitted).

- [ ] **Step 3: Implement**

In `InlineFormat#write`, before building `head_parts`, add:

```ruby
warn_missing_bundle unless iife_bundle_exists?
```

and as private methods:

```ruby
          def warn_missing_bundle
            return if self.class.missing_bundle_warned

            warn "metanorma-document: #{iife_bundle_path} not found — " \
                 "writing static HTML without the interactive SPA. " \
                 "Run `rake build_frontend` to build it."
            self.class.missing_bundle_warned = true
          end
```

plus `class << self; attr_accessor :missing_bundle_warned; end` inside the class.

(The spec uses a fresh class state; reset `described_class.missing_bundle_warned = false` in a `before` block.)

- [ ] **Step 4: Run spec, expect pass**

Run: `bundle exec rspec spec/metanorma/mirror/output/formats/`
Expected: PASS, including pre-existing format specs.

### Task 7: relaton-bib constraint test + dependency documentation

**Files:**
- Modify: `metanorma-document.gemspec:41-42`

- [ ] **Step 1: Probe stable relaton-bib 2.1.5**

Temporarily set: `spec.add_dependency "relaton-bib", "= 2.1.5"`, run `bundle update relaton-bib && bundle exec rspec`.
- If PASS → set final constraint to `spec.add_dependency "relaton-bib", ">= 2.1.5", "< 2.3.0"` and `bundle update relaton-bib` again.
- If FAIL with relaton-related errors → revert to `">= 2.2.0.pre.alpha.1", "< 2.3.0"`, `bundle update relaton-bib`, and record "relaton-bib pinned to 2.2 prerelease — code depends on 2.2-only API" in TODO.consolidated.md.

- [ ] **Step 2: Document the pubid pin**

Change the pubid line to:

```ruby
  # pubid has no stable 2.x release yet (latest: 2.0.0.pre.alpha.x);
  # relax this pin once pubid 2.0.0 ships.
  spec.add_dependency "pubid", "~> 2.0.0.pre.alpha"
```

### Task 8: CI honesty — roundtrip workflow + edge-deps workflow

**Files:**
- Modify: `.github/workflows/roundtrip-samples.yml` (remove `continue-on-error: true` at lines 91 and 124 — consolidate already `exit(1)`s on failures at tasks/roundtrip_samples.rake:98; the workflow is schedule/dispatch-only, so red runs are signal, not blockage)
- Create: `.github/workflows/edge.yml`

- [ ] **Step 1: Delete the two `continue-on-error: true` lines.**

- [ ] **Step 2: Create `.github/workflows/edge.yml`** (preserves the bleeding-edge signal CI used to provide via `ENV["CI"]`):

```yaml
name: edge-deps

on:
  schedule:
    - cron: '23 5 * * 1'
  workflow_dispatch:

permissions:
  contents: read

jobs:
  rspec:
    runs-on: ubuntu-latest
    env:
      METANORMA_CI_EDGE: "1"
    steps:
      - uses: actions/checkout@v4
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
          bundler-cache: true
      - name: Run specs against upstream main branches
        run: bundle exec rspec
```

- [ ] **Step 3: Validate YAML**

Run: `ruby -ryaml -e 'YAML.safe_load_file(".github/workflows/edge.yml"); YAML.safe_load_file(".github/workflows/roundtrip-samples.yml"); puts "ok"'`
Expected: `ok`.

### Task 9: Housekeeping — archive fully-done TODO dirs

**Files:**
- Move (plain `mv`, all git-ignored under `TODO*`): `BUGS.sts`, `TODO.bugs`, `TODO.schema`, `TODO.fidelity`, `TODO.html-audit`, `TODO.html-refactor`, `TODO.mn-mirror`, `TODO.more-flavors`, `TODO.refact`, `TODO.equiv-pdf`, `TODO.flavor-roots`, `TODO.fixup`, `TODO.refactor.md` → into new `TODO.done/`
- Modify: `TODO.consolidated.md` (note the archive)

- [ ] **Step 1: Move**

Run: `mkdir -p TODO.done && mv BUGS.sts TODO.bugs TODO.schema TODO.fidelity TODO.html-audit TODO.html-refactor TODO.mn-mirror TODO.more-flavors TODO.refact TODO.equiv-pdf TODO.flavor-roots TODO.fixup TODO.refactor.md TODO.done/`

Stays at root (still has open items, or git-tracked): `TODO.finalize` (tracked; item 07 open), `TODO.improvements`, `TODO.pdf-diff`, `TODO.pres-xml`, `TODO.roundtrips`, `TODO.round-trips-samples`, `TODO.polymorphic-grouping.md`, `TODO.consolidated.md`.

- [ ] **Step 2: Add an archive note at the top of TODO.consolidated.md**

```markdown
> Archive note (2026-07-19): all fully-done/completed plan dirs were moved to
> `TODO.done/`. References below to e.g. `TODO.bugs/...` now live under
> `TODO.done/TODO.bugs/...`. Open work remains at the paths listed.
```

### Task 10: Full verification gate

- [ ] **Step 1: Full suite** — Run: `bundle exec rspec` — Expected: no worse than the Task 1 baseline; ideally all green.
- [ ] **Step 2: Lint** — Run: `bundle exec rubocop Gemfile Rakefile metanorma-document.gemspec lib/metanorma/html/flavor.rb lib/metanorma/html/generator.rb lib/metanorma/mirror/output/formats/inline_format.rb spec/metanorma/html/flavor_spec.rb spec/metanorma/mirror/output/formats/inline_format_missing_bundle_spec.rb` — Expected: no offenses (fix or regenerate baseline entries if new ones appear).
- [ ] **Step 3: Update TODO.consolidated.md** — mark P0 items 1-5 and Housekeeping 25 as DONE with one-line outcomes (incl. relaton-bib probe result and any pubid modules dropped in Task 5).

## Self-Review Notes

- Spec coverage: P0.1 → Tasks 3+4+6; P0.2 → Task 5; P0.3 → Tasks 3+8; P0.4 → Tasks 1+8; P0.5 → Task 7; Housekeeping 25 → Task 9. Covered.
- Placeholder scan: Task 6 Step 1's `guide` shape is the only "check existing spec" moment — executor must copy the minimal guide from an existing inline_format spec; everything else is exact code.
- Type consistency: `pubid_module_const` semantics (nil | Module | raise) match between flavor.rb, the registry sweep spec, and `FlavorRegistry#pubid_module_for` (which surfaces the raise — intended loud failure).
- Commits are intentionally absent (user reviews the full diff first).
