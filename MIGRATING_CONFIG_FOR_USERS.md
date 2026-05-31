# Migrating Your Configuration File

This guide covers the changes you need to make to your `config/i18n.yml` (or
equivalent) after the switch to the `pipeline:` API.

---

## What changed

Plugin configuration used to live at the top level of the config file, each
plugin using its own root key. All plugins are now listed in a single
`pipeline:` array. The order of entries in the array determines the order in
which plugins run.

---

## 1. `embed_fallback_translations`

**Before**

```yaml
translations:
  - file: app/javascript/locales/%{locale}.json
    patterns:
      - "*"

embed_fallback_translations:
  enabled: true
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
```

---

## 2. `export_files`

**Before**

```yaml
translations:
  - file: app/javascript/locales/%{locale}.json
    patterns:
      - "*"

export_files:
  enabled: true
  files:
    - template: path/to/template.erb
      output: "%{dir}/%{base_name}.ts"
```

**After**

```yaml
translations:
  - file: app/javascript/locales/%{locale}.json
    patterns:
      - "*"

pipeline:
  - plugin: export_files
    enabled: true
    files:
      - template: path/to/template.erb
        output: "%{dir}/%{base_name}.ts"
```

Plugin-specific keys (`files:` in this case) move into the pipeline stage
object, directly alongside `plugin:` and `enabled:`.

---

## 3. Multiple plugins

When you use more than one plugin, list them all under the same `pipeline:`
key. The plugins run in the order they are listed.

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
    - template: path/to/template.erb
      output: "%{dir}/%{base_name}.ts"
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
      - template: path/to/template.erb
        output: "%{dir}/%{base_name}.ts"
```

---

## 4. Temporarily disabling a plugin

Set `enabled: false` on the pipeline stage. The stage stays in the file so you
can re-enable it without rewriting the config.

```yaml
pipeline:
  - plugin: embed_fallback_translations
    enabled: false   # temporarily disabled
```

Previously, removing the top-level key was the only way to disable a plugin.

---

## 5. Running the same plugin more than once

The pipeline allows the same plugin to appear multiple times with different
options. This was not possible with the old top-level key approach.

```yaml
pipeline:
  - plugin: export_files
    enabled: true
    files:
      - template: templates/esm.erb
        output: "%{dir}/%{base_name}.mjs"

  - plugin: export_files
    enabled: true
    files:
      - template: templates/cjs.erb
        output: "%{dir}/%{base_name}.cjs"
```

---

## 6. The `check` key was removed

The `check:` root key is no longer a recognised configuration option and will
cause a validation error if present. Remove it from your config file.

**Before**

```yaml
check:
  ignore:
    - "es.bye"
    - "pt.bye"
```

**After** — delete the `check:` block entirely. There is no replacement in the
current version.

---

## Quick checklist

- [ ] Remove the top-level `embed_fallback_translations:` block and replace with a `pipeline:` entry
- [ ] Remove the top-level `export_files:` block and replace with a `pipeline:` entry (move `files:` into the stage)
- [ ] Do the same for any third-party plugin that had its own top-level key
- [ ] Remove the `check:` block if present
- [ ] Verify the `pipeline:` key is a YAML sequence (starts with `-`), not a mapping
