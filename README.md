<p align="center">
  <img width="250" height="58" src="https://github.com/fnando/i18n-js/raw/main/images/i18njs.png" alt="i18n.js">
</p>

<p align="center">
  Export <a href="https://rubygems.org/gems/i18n">i18n</a> translations to JSON.
  <br>
  A perfect fit if you want to export translations to JavaScript.
</p>

<p align="center">
  <small>
    Oh, you don't use Ruby? No problem! You can still use i18n-js
    <br>
    and the
    <a href="https://www.npmjs.com/package/i18n-js/v/latest">companion JavaScript package</a>.
  </small>
</p>

<p align="center">
  <a href="https://github.com/fnando/i18n-js"><img src="https://github.com/fnando/i18n-js/workflows/ruby-tests/badge.svg" alt="Tests"></a>
  <a href="https://rubygems.org/gems/i18n-js"><img src="https://img.shields.io/gem/v/i18n-js.svg" alt="Gem"></a>
  <a href="https://rubygems.org/gems/i18n-js"><img src="https://img.shields.io/gem/dt/i18n-js.svg" alt="Gem"></a>
  <a href="https://tldrlegal.com/license/mit-license"><img src="https://img.shields.io/:License-MIT-blue.svg" alt="MIT License"></a>
</p>

## Installation

```bash
gem install i18n-js
```

Or add the following line to your project's Gemfile:

```ruby
gem "i18n-js"
```

Create a default configuration file in ./config/i18n.yml

```bash
i18n init
```

## Usage

About patterns:

- Patterns can use `*` as a wildcard and can appear more than once.
  - `*` will include everything
  - `*.messages.*`
- Patterns starting with `!` are excluded.
  - `!*.activerecord.*` will exclude all ActiveRecord translations.
- You can use groups:
  - `{pt-BR,en}.js.*` will include only `pt-BR` and `en` translations, even if
    more languages are available.

> **Note**:
>
> Patterns use [glob](https://rubygems.org/gems/glob), so check it out for the
> most up-to-date documentation about what's available.

The config file:

```yml
---
translations:
  - file: app/frontend/locales/en.json
    patterns:
      - "*"
      - "!*.activerecord"
      - "!*.errors"
      - "!*.number.nth"

  - file: app/frontend/locales/:locale.:digest.json
    patterns:
      - "*"
```

The output path can use the following placeholders:

- `:locale` - the language that's being exported.
- `:digest` - the MD5 hex digest of the exported file.

The example above could generate a file named
`app/frontend/locales/en.7bdc958e33231eafb96b81e3d108eff3.json`.

The config file is processed as erb, so you can have dynamic content on it if
you want. The following example shows how to use groups from a variable.

```yml
---
<% group = "{en,pt}" %>

translations:
  - file: app/frontend/translations.json
    patterns:
      - "<%= group %>.*"
      - "!<%= group %>.activerecord"
      - "!<%= group %>.errors"
      - "!<%= group %>.number.nth"
```

### Exporting locale.yml to locale.json

Your i18n yaml file can be exported to JSON using the Ruby API or the command
line utility. Examples of both approaches are provided below:

The Ruby API:

```ruby
require "i18n-js"

# The following call performs the same task as the CLI `i18n export` command
I18nJS.call(config_file: "config/i18n.yml")

# You can provide the config directly using the following
config = {
  "translations"=>[
    {"file"=>"app/javascript/locales/:locale.json", "patterns"=>["*"]}
  ]
}

I18nJS.call(config: config)
#=> ["app/javascript/locales/de.json", "app/javascript/locales/en.json"]
```

The CLI API:

```console
$ i18n --help
Usage: i18n COMMAND FLAGS

Commands:

- init: Initialize a project
- export: Export translations as JSON files
- version: Show package version
- plugins: List plugins that will be activated
- lint:translations: Check for missing translations
- lint:scripts: Lint files using TypeScript

Run `i18n COMMAND --help` for more information on specific commands.
```

By default, `i18n` will use `config/i18n.yml` and `config/environment.rb` as the
configuration files. If you don't have these files, then you'll need to specify
both `--config` and `--require`.

### Plugins

#### Built-in plugins:

##### `embed_fallback_translations`:

Embed fallback translations inferred from the default locale. This can be useful
in cases where you have multiple large translation files and don't want to load
the default locale together with the target locale.

To use it, add the following to your configuration file:

```yaml
---
embed_fallback_translations:
  enabled: true
```

##### `export_files`:

By default, i18n-js will export only JSON files out of your translations. This
plugin allows exporting other file formats. To use it, add the following to your
configuration file:

```yaml
---
export_files:
  enabled: true
  files:
    - template: path/to/template.erb
      output: "%{dir}/%{base_name}.ts"
```

You can export multiple files by defining more entries.

The output name can use the following placeholders:

- `%{dir}`: the directory where the translation file is.
- `%{name}`: file name with extension.
- `%{base_name}`: file name without extension.
- `%{digest}`: MD5 hexdigest from the generated file.

The template file must be a valid eRB template. You can execute arbitrary Ruby
code, so be careful. An example of how you can generate a file can be seen
below:

```erb
/* eslint-disable */
<%= banner %>

import { i18n } from "config/i18n";

i18n.store(<%= JSON.pretty_generate(translations) %>);
```

This template is loading the instance from `config/i18n` and storing the
translations that have been loaded. The
`banner(comment: "// ", include_time: true)` method is built-in. The generated
file will look something like this:

```typescript
/* eslint-disable */
// File generated by i18n-js on 2022-12-10 15:37:00 +0000

import { i18n } from "config/i18n";

i18n.store({
  en: {
    "bunny rabbit adventure": "bunny rabbit adventure",
    "hello sunshine!": "hello sunshine!",
    "time for bed!": "time for bed!",
  },
  es: {
    "bunny rabbit adventure": "conejito conejo aventura",
    bye: "adios",
    "time for bed!": "hora de acostarse!",
  },
  pt: {
    "bunny rabbit adventure": "a aventura da coelhinha",
    bye: "tchau",
    "time for bed!": "hora de dormir!",
  },
});
```

#### Plugin API

You can transform the exported translations by adding plugins. A plugin must
inherit from `I18nJS::Plugin` and can have 4 class methods (they're all optional
and will default to a noop implementation). For real examples, see
[lib/i18n-js/embed_fallback_translations_plugin.rb](https://github.com/fnando/i18n-js/blob/main/lib/i18n-js/embed_fallback_translations_plugin.rb)
and
[lib/i18n-js/export_files_plugin.rb](https://github.com/fnando/i18n-js/blob/main/lib/i18n-js/export_files_plugin.rb)

```ruby
# frozen_string_literal: true

module I18nJS
  class SamplePlugin < I18nJS::Plugin
    # This method is responsible for transforming the translations. The
    # translations you'll receive may be already be filtered by other plugins
    # and by the default filtering itself. If you need to access the original
    # translations, use `I18nJS.translations`.
    def transform(translations:)
      # transform `translations` here…

      translations
    end

    # In case your plugin accepts configuration, this is where you must validate
    # the configuration, making sure only valid keys and type is provided.
    # If the configuration contains invalid data, then you must raise an
    # exception using something like
    # `raise I18nJS::Schema::InvalidError, error_message`.
    #
    # Notice the validation will only happen when the plugin configuration is
    # set (i.e. the configuration contains your config key).
    def validate_schema
      # validate plugin schema here…
    end

    # This method must set up the basic plugin configuration, like adding the
    # config's root key in case your plugin accepts configuration (defined via
    # the config file).
    #
    # If you don't add this key, the linter will prevent non-default keys from
    # being added to the configuration file.
    def setup
      # If you plugin has configuration, uncomment the line below
      # I18nJS::Schema.root_keys << config_key
    end

    # This method is called whenever `I18nJS.call(**kwargs)` finishes exporting
    # JSON files based on your configuration.
    #
    # You can use it to further process exported files, or generate new files
    # based on the translations that have been exported.
    def after_export(files:)
      # process exported files here…
    end
  end
end
```

The class `I18nJS::Plugin` implements some helper methods that you can use:

- `I18nJS::Plugin#config_key`: the configuration key that was inferred out of
  your plugin's class name.
- `I18nJS::Plugin#config`: the plugin configuration.
- `I18nJS::Plugin#enabled?`: whether the plugin is enabled or not based on the
  plugin's configuration.

To distribute this plugin, you need to create a gem package that matches the
pattern `i18n-js/*_plugin.rb`. You can test whether your plugin will be found by
installing your gem, opening a iRB session and running
`Gem.find_files("i18n-js/*_plugin.rb")`. If your plugin is not listed, then you
need to double check your gem load path and see why the file is not being
loaded.

### Listing missing translations

To list missing and extraneous translations, you can use
`i18n lint:translations`. This command will load your translations similarly to
how `i18n export` does, but will output the list of keys that don't have a
matching translation against the default locale. Here's an example:

```console
$ i18n lint:translations
=> Config file: "./config/i18n.yml"
=> Require file: "./config/environment.rb"
=> Check "./config/i18n.yml" for ignored keys.
=> en: 232 translations
=> pt-BR: 5 missing, 1 extraneous, 1 ignored
   - pt-BR.actors.github.metrics (missing)
   - pt-BR.actors.github.metrics_hint (missing)
   - pt-BR.actors.github.repo_metrics (missing)
   - pt-BR.actors.github.repository (missing)
   - pt-BR.actors.github.user_metrics (missing)
   - pt-BR.github.repository (extraneous)
```

This command will exit with status 1 whenever there are missing translations.
This way you can use it as a CI linting tool.

You can ignore keys by adding a list to the config file:

```yml
---
translations:
  - file: app/frontend/locales/en.json
    patterns:
      - "*"
      - "!*.activerecord"
      - "!*.errors"
      - "!*.number.nth"

  - file: app/frontend/locales/:locale.:digest.json
    patterns:
      - "*"

lint_translations:
  ignore:
    - en.mailer.login.subject
    - en.mailer.login.body
```

> **Note**:
>
> In order to avoid mistakenly ignoring keys, this configuration option only
> accepts the full translation scope, rather than accepting a pattern like
> `pt.ignored.scope.*`.

### Linting your JavaScript/TypeScript files

To lint your script files and check for missing translations (which can signal
that you're either using wrong scopes or forgot to add the translation), use
`i18n lint:scripts`. This command will parse your JavaScript/TypeScript files
and extract all scopes being used. This command requires a Node.js runtime. You
can either specify one via `--node-path`, or let the plugin infer a binary from
your `$PATH`.

The comparison will be made against the export JSON files, which means it'll
consider transformations performed by plugins (e.g. the output files may be
affected by `embed_fallback_translations` plugin).

The translations that will be extract must be called as one of the following
ways:

- `i18n.t(scope, options)`
- `i18n.translate(scope, options)`
- `t(scope, options)`

Notice that only literal strings can be used, as in `i18n.t("message")`. If
you're using dynamic scoping through variables (e.g.
`const scope = "message"; i18n.t(scope)`), they will be skipped.

```console
$ i18n lint:scripts
=> Config file: "./config/i18n.yml"
=> Require file: "./config/environment.rb"
=> Node: "/Users/fnando/.asdf/shims/node"
=> Available locales: [:en, :es, :pt]
=> Patterns: ["!(node_modules)/**/*.js", "!(node_modules)/**/*.ts", "!(node_modules)/**/*.jsx", "!(node_modules)/**/*.tsx"]
=> 9 translations, 11 missing, 4 ignored
   - test/scripts/lint/file.js:1:1: en.js.missing
   - test/scripts/lint/file.js:1:1: es.js.missing
   - test/scripts/lint/file.js:1:1: pt.js.missing
   - test/scripts/lint/file.js:2:8: en.base.js.missing
   - test/scripts/lint/file.js:2:8: es.base.js.missing
   - test/scripts/lint/file.js:2:8: pt.base.js.missing
   - test/scripts/lint/file.js:4:8: en.js.missing
   - test/scripts/lint/file.js:4:8: es.js.missing
   - test/scripts/lint/file.js:4:8: pt.js.missing
   - test/scripts/lint/file.js:6:1: en.another_ignore_scope
   - test/scripts/lint/file.js:6:1: es.another_ignore_scope
```

This command will list all locales and their missing translations. To avoid
listing a particular translation, you can set `lint_scripts.ignore` or
`lint_translations.ignore` in your config file.

```yaml
---
translations:
  - file: app/frontend/translations.json
    patterns:
      - "*"

lint_scripts:
  ignore:
    - ignore_scope # will ignore this scope on all languages
    - pt.another_ignore_scope # will ignore this scope only on `pt`
```

You can also set the patterns that will be looked up. By default, it scans all
JavaScript and TypeScript files that don't live on `node_modules`.

```yaml
---
translations:
  - file: app/frontend/translations.json
    patterns:
      - "*"

lint_scripts:
  patterns:
    - "app/assets/**/*.ts"
```

## Automatically export translations

### Using [watchman](https://facebook.github.io/watchman/)

Create a script at `bin/i18n-watch`.

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
      ["match", "config/i18n.yml", "wholename"]
    ],
    "command": ["i18n", "export"]
  }
]
JSON

# If you're running this through Foreman,
# then uncomment the following lines:
# while true; do
#   sleep 1
# done
```

Make it executable with `chmod +x bin/i18n-watch`. To watch for changes, run
`./bin/i18n-watch`. If you're using Foreman, make sure you uncommented the lines
that keep the process running (`while..`), and add something like the following
line to your Procfile:

```
i18n: ./bin/i18n-watch
```

### Using [guard](https://rubygems.org/gems/guard)

Install [guard](https://rubygems.org/gems/guard) and
[guard-compat](https://rubygems.org/gems/guard-compat). Then create a Guardfile
with the following configuration:

```ruby
guard(:"i18n-js",
      run_on_start: true,
      config_file: "./config/i18n.yml",
      require_file: "./config/environment.rb") do
  watch(%r{^(app|config)/locales/.+\.(yml|po)$})
  watch(%r{^config/i18n.yml$})
  watch("Gemfile")
end
```

If your files are located in a different path, remember to configure file paths
accordingly.

Now you can run `guard start -i`.

### Using [listen](https://rubygems.org/gems/listen)

Create a file under `config/initializers/i18n.rb` with the following content:

```ruby
Rails.application.config.after_initialize do
  require "i18n-js/listen"
  I18nJS.listen
end
```

The code above will watch for changes based on `config/i18n.yml` and
`config/locales`. You can customize these options:

- `config_file` - i18n-js configuration file
- `locales_dir` - one or multiple directories to watch for locales changes
- `options` - passed directly to
  [listen](https://github.com/guard/listen/#options)
- `run_on_start` - export files on start. Defaults to `true`. When disabled,
  files will be exported only when there are file changes.

Example:

```ruby
I18nJS.listen(
  config_file: "config/i18n.yml",
  locales_dir: ["config/locales", "app/views"],
  options: {only: %r{.yml$}},
  run_on_start: false
)
```

### Integrating with your frontend

You're done exporting files, now what? Well, go to
[i18n](https://github.com/fnando/i18n) to discover how to use the NPM package
that loads all the exported translation.

### FAQ

#### I'm running v3. Is there a migration plan?

[There's a document](https://github.com/fnando/i18n-js/tree/main/MIGRATING_FROM_V3_TO_V4.md)
outlining some of the things you need to do to migrate from v3 to v4. It may not
be as complete as we'd like it to be, so let us know if you face any issues
during the migration that is not outlined in that document.

#### How can I export translations without having a database around?

Some people may have a build process using something like Docker that don't
necessarily have a database available. In this case, you may define your own
loading file by using something like
`i18n export --require ./config/i18n_export.rb`, where `i18n_export.rb` may look
like this:

```ruby
# frozen_string_literal: true

require "bundler/setup"
require "rails"
require "active_support/railtie"
require "action_view/railtie"

I18n.load_path += Dir["./config/locales/**/*.yml"]
```

> **Note**:
>
> You may not need to load the ActiveSupport and ActionView lines, or you may
> need to add additional requires for other libs. With this approach you have
> full control on what's going to be loaded.

## Maintainer

- [Nando Vieira](https://github.com/fnando)

## Contributors

- https://github.com/fnando/i18n-js/contributors

## Contributing

For more details about how to contribute, please read
https://github.com/fnando/i18n-js/blob/main/CONTRIBUTING.md.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT). A copy of the license can be
found at https://github.com/fnando/i18n-js/blob/main/LICENSE.md.

## Code of Conduct

Everyone interacting in the i18n-js project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/fnando/i18n-js/blob/main/CODE_OF_CONDUCT.md).
