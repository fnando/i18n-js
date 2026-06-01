# Migrating Plugins to the Pipeline API

This guide covers the breaking changes to the plugin API introduced in the
commit that switched plugins from top-level config keys to a `pipeline` array.

---

## Overview of changes

| Area | Before | After |
|------|--------|-------|
| Config location | Top-level key per plugin | `pipeline:` array |
| Key method | `config_key` (instance, Symbol) | `Plugin.key` (class method, String) |
| Constructor | `initialize(config:)` | `initialize(plugin_config:, main_config:)` |
| `config` accessor | `main_config[config_key]` | plugin-specific hash from pipeline entry |
| `setup` | registers root schema key | no schema registration needed |
| `validate_schema` paths | prefixed with `config_key` | relative to plugin config root |
| `I18nJS.plugins` | global accessor | return value of `initialize_plugins!` |
| `Schema.root_keys` | mutable Set | frozen Array |

---

## 1. Update the config file

Plugin configuration no longer lives at the top level of the YAML file. Move
every plugin block into the `pipeline:` array and add a `plugin:` key that
identifies the plugin by its inferred key name (snake_case, no `Plugin`
suffix).

**Before**

```yaml
translations:
  - file: app/javascript/locales/%{locale}.json
    patterns:
      - "*"

embed_fallback_translations:
  enabled: true

export_files:
  enabled: true
  files:
    - template: templates/export.erb
      output: "%{dir}/%{base_name}-%{digest}.ts"
```

**After**

```yaml
translations:
  - file: app/javascript/locales/%{locale}.json
    patterns:
      - "*"

pipeline:
  - plugin: embed_fallback_translations
    enabled: true

  - plugin: export_files
    enabled: true
    files:
      - template: templates/export.erb
        output: "%{dir}/%{base_name}-%{digest}.ts"
```

All plugin-specific keys (like `files:` above) now live directly inside the
pipeline stage object, alongside `plugin:` and `enabled:`.

---

## 2. Rename `config_key` to `Plugin.key`

The method that infers the plugin's identifier moved from an **instance**
method returning a Symbol to a **class** method returning a String.

**Before**

```ruby
# instance method, returns Symbol
def config_key
  :my_plugin
end
```

**After**

```ruby
# class method, returns String
def self.key
  "my_plugin"
end
```

In most cases you do **not** need to override this method at all — it is
automatically inferred from the class name:

| Class name | Inferred key |
|------------|-------------|
| `SamplePlugin` | `"sample"` |
| `EmbedFallbackTranslationsPlugin` | `"embed_fallback_translations"` |
| `FetchFromHTTPPlugin` | `"fetch_from_http"` |

Override only if the inferred name does not match what you want to expose in the
config file.

---

## 3. Update the constructor

The constructor signature changed. `config:` (the full main config) was
replaced by two keyword arguments.

**Before**

```ruby
def initialize(config:)
  @main_config = config
  @schema      = I18nJS::Schema.new(@main_config)
end
```

**After**

The base class handles initialization. You rarely need to override `initialize`
at all. If you do, call `super` and use the provided accessors:

```ruby
def initialize(plugin_config:, main_config:)
  super
  # @config      => plugin-specific hash (the pipeline stage, minus :plugin key)
  # @main_config => full config hash
  # @schema      => Schema.new(@config)
end
```

---

## 4. Use `config` instead of `main_config[config_key]`

`config` now returns only the plugin's own slice of configuration (the pipeline
stage hash, with the `plugin:` key removed). You no longer need to dig into
`main_config` to find your plugin's settings.

**Before**

```ruby
def transform(translations:)
  return translations unless main_config[config_key][:enabled]
  # work with main_config[config_key][:my_option]
end
```

**After**

```ruby
def transform(translations:)
  # work with config[:my_option] directly
end
```

`enabled?` is also handled by the base class and returns `config[:enabled]`.
Only enabled plugins are placed in the pipeline, so you rarely need to check
`enabled?` inside `transform`.

---

## 5. Remove schema root key registration from `setup`

Plugins used to register their top-level config key so the schema validator
wouldn't reject it. This is no longer necessary — the `pipeline:` array is
already a recognised root key, and each stage is validated generically.

**Before**

```ruby
def setup
  I18nJS::Schema.root_keys << config_key
end
```

**After**

```ruby
def setup
  # plugin-specific setup only, no schema registration needed
end
```

If `setup` contained only the `root_keys <<` line, you can delete the method
entirely.

---

## 6. Update `validate_schema` paths

`Schema` is now initialized with the plugin's own config hash rather than the
full main config. All paths passed to schema helpers are therefore **relative to
the plugin config root**, not the global config root.

**Before**

```ruby
def validate_schema
  valid_keys = %i[enabled files]

  schema.expect_required_keys(keys: valid_keys, path: [config_key])
  schema.reject_extraneous_keys(keys: valid_keys, path: [config_key])
  schema.expect_array_with_items(path: [config_key, :files])

  config[:files].each_with_index do |_, index|
    export_keys = %i[template output]
    schema.expect_required_keys(keys: export_keys, path: [config_key, :files, index])
    schema.expect_type(path: [config_key, :files, index, :template], types: String)
  end
end
```

**After**

```ruby
def validate_schema
  valid_keys = %i[enabled files]

  schema.expect_required_keys(keys: valid_keys)          # path defaults to []
  schema.reject_extraneous_keys(keys: valid_keys)
  schema.expect_array_with_items(path: [:files])         # relative path

  export_keys = %i[template output]
  config[:files].each_with_index do |_, index|
    schema.expect_required_keys(keys: export_keys, path: [:files, index])
    schema.expect_type(path: [:files, index, :template], types: String)
  end
end
```

The rule: **drop the leading `config_key` segment from every path**.

---

## 7. Stop using `I18nJS.plugins`

The global `I18nJS.plugins` accessor was removed. `initialize_plugins!` now
returns the list of active plugin instances directly.

**Before**

```ruby
I18nJS.initialize_plugins!(config:)
I18nJS.plugins.each { |p| p.do_something }
```

**After**

```ruby
plugins = I18nJS.initialize_plugins!(config:)
plugins.each { |p| p.do_something }
```

If you were calling `I18nJS.plugins.clear` in tests, switch to
`I18nJS.available_plugins.clear` (which clears registered plugin classes) or
simply stop clearing — `initialize_plugins!` now reads solely from the
`pipeline:` config so stale instances are never carried over.

---

## 8. One plugin class, multiple pipeline stages

A single plugin class can now appear **multiple times** in the pipeline with
different configurations. Each entry creates an independent plugin instance.
Each instance receives its own `config` hash.

```yaml
pipeline:
  - plugin: export_files
    enabled: true
    files:
      - template: templates/esm.erb
        output: "app/js/%{base_name}.mjs"

  - plugin: export_files
    enabled: true
    files:
      - template: templates/cjs.erb
        output: "app/js/%{base_name}.cjs"
```

---

## Quick checklist

- [ ] Move all plugin blocks from the top level into a `pipeline:` array
- [ ] Add a `plugin:` key to each pipeline stage
- [ ] Rename `config_key` instance method to `self.key` class method; change return type from Symbol to String
- [ ] Remove `initialize` override if it only delegated to `super`; otherwise update signature to `(plugin_config:, main_config:)`
- [ ] Replace `main_config[config_key][:option]` with `config[:option]`
- [ ] Delete `setup` if it only registered a root schema key
- [ ] Drop the leading `config_key` segment from all `schema.*` paths in `validate_schema`
- [ ] Replace `I18nJS.plugins` with the return value of `initialize_plugins!`
