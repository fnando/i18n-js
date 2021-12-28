# i18n-js

[![Tests](https://github.com/fnando/i18n-js/workflows/ruby-tests/badge.svg)](https://github.com/fnando/i18n-js)
[![Code Climate](https://codeclimate.com/github/fnando/i18n-js/badges/gpa.svg)](https://codeclimate.com/github/fnando/i18n-js)
[![Gem](https://img.shields.io/gem/v/i18n-js.svg)](https://rubygems.org/gems/i18n-js)
[![Gem](https://img.shields.io/gem/dt/i18n-js.svg)](https://rubygems.org/gems/i18n-js)

Export [i18n](https://rubygems.org/gems/i18n) translations to JSON. A perfect
fit if you want to export translations to JavaScript.

Oh, you don't use Ruby? No problem! You can still use i18n-js and the
[companion JavaScript package](https://npmjs.com/package/i18n-js).

## Installation

```bash
gem install i18n-js
```

Or add the following line to your project's Gemfile:

```ruby
gem "i18n-js", "~> 4.0.0.alpha1"
```

## Usage

About patterns:

- Patterns can use `*` as a wildcard and can appear more than once.
  - `*` will include everything
  - `*.messages.*`
- Patterns starting with `!` are excluded.
  - `!*.activerecord.*` will exclude all ActiveRecord translations.

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

  - file: app/frontend/locales/:locale.json
    patterns:
      - "*"
```

The Ruby API:

```ruby
require "i18n-js"

I18nJS.call(config_file: "config/i18n.yml")
I18nJS.call(config: config)
```

The CLI API:

```console
$ i18n init --config config/i18n.yml
$ i18n export --config config/i18n.yml --require config/environment.rb
```

By default, `i18n` will use `config/i18n.yml` and `config/environment.rb` as the
configuration files. If you don't have these files, then you'll need to specify
both `--config` and `--require`.

## Automatically export translations

### Using guard

Install [guard](https://rubygems.org/packages/guard) and
[guard-compat](https://rubygems.org/packages/guard-compat). Then create a
Guardfile with the following configuration:

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

If you files in a different location, the remember to configure file paths
accordingly.

Now you can run `guard start -i`.

### Using listen

Create a file under `config/initializers/i18n.rb` with the following content:

```ruby
Rails.application.config.after_initialize do
  require "i18n-js/listen"
  I18nJS.listen
end
```

The code above will watch for changes based on `config/i18n.yml` and
`config/locales`. You can customize these options with
`I18nJS.listen(config_file: "config/i18n.yml", locales_dir: "config/locales")`.

### Integrating with your frontend

You're done exporting files, now what? Well, go to
[i18n](https://github.com/fnando/i18n) to discover how to use the NPM package
that loads all the exported translation.

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
