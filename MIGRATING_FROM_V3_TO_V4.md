# Migrating from v3 to v4

I18n-js v4 is a breaking change release and diverges quite a lot from how the
previous version worked. This guides summarizes the process of upgrading an app
that uses i18n-js v3 to v4.

## Development

Previously, you could use a middleware to export translations (some people even
used this in production 😬). In development, you can now use whatever your want,
because i18n-js doesn't make any assumptions. All you need to do is running
`i18n export`, either manually or by using something that listens to file
changes.

If you like watchman, you can use something like this:

```bash
#!/usr/bin/env bash

root=`pwd`

watchman watch-del "$root"
watchman watch-project "$root"
watchman trigger-del "$root" i18n

watchman -j <<-JSON
[
  "trigger",
  "$root",
  {
    "name": "i18n",
    "expression": [
      "anyof",
      ["match", "config/locales/**/*.yml", "wholename"],
      ["match", "config/locales/**/*.po", "wholename"],
      ["match", "config/i18n.yml", "wholename"]
    ],
    "command": ["i18n", "export"]
  }
]
JSON

# If you're running this through Foreman, then uncomment the following lines:
# while true; do
#   sleep 1
# done
```

You can also use guard. Make sure you have both
[guard](https://rubygems.org/gems/guard) and
[guard-compat](https://rubygems.org/gems/guard-compat) installed and use
Guardfile file with the following contents:

```ruby
guard(:"i18n-js",
      run_on_start: true,
      config_file: "./config/i18n.yml",
      require_file: "./config/environment.rb") do
  watch(%r{^config/locales/.+\.(yml|po)$})
  watch(%r{^config/i18n.yml$})
  watch("Gemfile")
end
```

To run guard, use `guard start -i`.

Finally, you can use [listen](https://rubygems.org/gems/listen). Create the file
`config/initializers/i18n.rb` with the following content:

```ruby
Rails.application.config.after_initialize do
  require "i18n-js/listen"
  # This will only run in development.
  I18nJS.listen
end
```

> **Warning**:
>
> No matter which approach you choose, the idea is that you _precompile_ your
> translations when going to production. DO NOT RUN any of the above in
> production.

## Exporting translations

The build process for i18n now relies on an external CLI called `i18n`. All you
need to do is executing `i18n export` in your build step to generate the json
files for your translations.

## Using your translations

The JavaScript package is now a separate thing and need to be installed using
your favorite tooling (e.g. yarn, npm, pnpm, etc).

```console
$ yarn add i18n-js@latest
$ npm i --save-dev i18n-js@latest
```

From now on, the way you load translations and set up I18n-js is totally up to
you, but means you need to load the json files and attach to the I18n-js
instance. This is how I do it in a project I'm doing right now (Rails 7 +
esbuild + TypeScript). First, we need to load the I18n-js configuration from the
main JavaScript file:

```typescript
// app/javascript/application.ts
import { i18n } from "./config/i18n";
```

Then we need to load our translations and instantiate the I18n-js class.

```typescript
// app/javascript/config/i18n.ts
import { I18n } from "i18n-js";
import translations from "translations.json";

// Fetch user locale from html#lang.
// This value is being set on `app/views/layouts/application.html.erb` and
// is inferred from `ACCEPT-LANGUAGE` header.
const userLocale = document.documentElement.lang;

export const i18n = new I18n();
i18n.store(translations);
i18n.defaultLocale = "en";
i18n.enableFallback = true;
i18n.locale = userLocale;
```

The best thing about the above is that it is a pretty straightforward pattern in
the JavaScript community. It doesn't rely on specific parts from Sprockets (I'm
not even using it on my projects) or eRb files.

## Ruby on Rails

### Upgrading the configuration file

The configuration file loaded from `config/i18n.yml` has changed. Given the v3
configuration below

```yaml
---
translations:
  - file: "app/assets/javascripts/date_formats.js"
    only: "*.date.formats"
  - file: "app/assets/javascripts/other.js"
    only: ["*.activerecord", "*.admin.*.title"]
  - file: "app/assets/javascripts/everything_else.js"
    except:
      - "*.activerecord"
      - "*.admin.*.title"
      - "*.date.formats"
```

the equivalent configuration file for v4 would be

```yaml
---
translations:
  - file: "app/assets/javascripts/date_formats.js"
    patterns:
      - "*.date.formats"
  - file: "app/assets/javascripts/other.js"
    patterns:
      - "*.activerecord"
      - "*.admin.*.title"
  - file: "app/assets/javascripts/everything_else.js"
    patterns:
      # Notice the exclamation mark.
      - "*"
      - "!*.activerecord"
      - "!*.admin.*.title"
      - "!*.date.formats"
```

Other configuration options:

- `export_i18n_js`: replaced by [export_files plugin](https://github.com/fnando/i18n-js#export_files)
- `fallbacks`: replaced by [embed_fallback_translations plugin](https://github.com/fnando/i18n-js#embed_fallback_translations)
- `js_available_locales`: removed (on v4 you can use groups, like in
  `{pt-BR,en}.*`)
- `namespace`: removed without an equivalent
- `sort_translation_keys`: removed (on v4 keys will always be sorted)
- `translations[].prefix`: removed without an equivalent
- `translations[].pretty_print`: removed (on v4 files will always be exported in
  a readable format)

### Placeholders

Previously, v3 had the `%{locale}` placeholder, which can be used as part of the
directory and/or file name. Now, the syntax is just `:locale`. Additionally, you
can also use `:digest`, which uses a MD5 hex digest of the exported file.
