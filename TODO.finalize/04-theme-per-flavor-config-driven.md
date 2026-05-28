# 04 — Data-centric theme system: config files per flavor

## Problem
Theme configuration is currently hardcoded in each flavor renderer's `def theme` method as Ruby code. This means:
- Adding a new flavor requires writing Ruby code
- Theme data is scattered across 15 renderer files
- No external configuration possible
- Violates open/closed principle (must modify renderer to change colors)

## Current state
Each `*_renderer.rb` overrides `def theme` with a `Theme.new.tap` block:
```ruby
def theme
  @theme ||= Theme.new.tap do |t|
    t.primary = "#b3000c"
    t.accent = "#7a1f1f"
    # ... 20+ lines per flavor
  end
end
```

## Target: config-driven themes

### Theme config files
Create `data/themes/{flavor}.yaml` files:

```yaml
# data/themes/iso.yaml
primary: "#b3000c"
accent: "#7a1f1f"
gradient: "linear-gradient(135deg, #b3000c 0%, #cc2200 50%, #7a1f1f 100%)"
font_body: '"Source Serif 4", "Noto Serif", Georgia, serif'
font_sans: '"DM Sans", "Helvetica Neue", Arial, sans-serif'
dark:
  bg: "#1a0505"
  bg_light: "#2a1010"
```

```yaml
# data/themes/iec.yaml
primary: "#004071"
accent: "#c74634"
font_body: '"Crimson Pro", "Georgia", "Times New Roman", serif'
```

### Theme loading
`Theme` class should load from YAML config:
```ruby
class Theme
  def self.load(flavor_name)
    path = File.join(DATA_DIR, "themes", "#{flavor_name}.yaml")
    if File.exist?(path)
      from_yaml(File.read(path))
    else
      new # defaults
    end
  end
end
```

### Flavor resolution
Renderer base class resolves theme from the document's flavor:
```ruby
def theme
  @theme ||= Theme.load(flavor_name)
end
```

### Benefits
- Zero Ruby code to add a new flavor theme
- Themes can be customized without touching renderer code
- Easy to validate and diff theme configs
- Follows open/closed principle

## Steps
1. Extract all 15 flavor theme configs into `data/themes/{flavor}.yaml`
2. Add `Theme.from_yaml` / `Theme.load` class method
3. Update `BaseRenderer#theme` to use `Theme.load(flavor_name)`
4. Remove all `def theme` overrides from flavor renderers
5. Add `data/themes/default.yaml` for the base theme
6. Verify each flavor renders identically to current output
7. Add specs for theme loading and config validation

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
