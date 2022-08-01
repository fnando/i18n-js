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

- `:locale`: the language that's being exported.
- `:digest`: the MD5 hex digest of the exported file.

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

The Ruby API:

```ruby
require "i18n-js"

I18nJS.call(config_file: "config/i18n.yml")
I18nJS.call(config: config)
```

The CLI API:

```console
$ i18n --help
Usage: i18n COMMAND FLAGS

Commands:

- init: Initialize a project
- export: Export translations as JSON files
- version: Show package version
- check: Check for missing translations

Run `i18n COMMAND --help` for more information on specific commands.
```

By default, `i18n` will use `config/i18n.yml` and `config/environment.rb` as the
configuration files. If you don't have these files, then you'll need to specify
both `--config` and `--require`.

### Listing missing translations

To list missing and extraneous translations, you can use `i18n check`. This
command will load your translations similarly to how `i18n export` does, but
will output the list of keys that don't have a matching translation against the
default locale. Here's an example:

![`i18n check` command in action](https://github.com/fnando/i18n-js/raw/main/images/i18njs-check.gif)

This command will exist with status 1 whenever there are missing translations.
This way you can use it as a CI linting.

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

check:
  ignore:
    - en.mailer.login.subject
    - en.mailer.login.body
```

> **Note**:
>
> In order to avoid mistakenly ignoring keys, this configuration option only
> accepts the full translation scope, rather than accepting a pattern like
> `pt.ignored.scope.*`.

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
# the uncomment the following lines:
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
- `options` - passed directly to [listen](https://github.com/guard/listen/#options)
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
be as complete as we'd like it to be, so let's know if you face any issues
during the migration is not outline is that document.

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
> You may not need to load ActiveSupport and ActionView lines, or even may need
> to add additional requires for other libs. With this approach you have full
> control on what's going to be loaded.

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
