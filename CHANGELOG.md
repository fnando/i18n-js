
## Unreleased

### enhancements

- Add support for loading via AMD and CommonJS module loaders ([#266](https://github.com/fnando/i18n-js/pull/266))
- Add `I18n.nullPlaceholder`  
  Defaults to I18n.missingPlaceholder (`[missing {{name}} value]`)  
  Set to `function() {return "";}` to match Ruby `I18n.t("name: %{name}", name: nil)`

### bug fixes

- Fix pluralization rules selection for negative `count` (e.g. `-1` was lead to use `one` for pluralization) ([#268](https://github.com/fnando/i18n-js/pull/268))

## 3.0.0.rc7

### enhancements

- The Rails Engine initializer is now named as `i18n-js.register_preprocessor` (https://github.com/fnando/i18n-js/pull/261)
- Rename `I18n::JS.config_file` to `I18n::JS.config_file_path` and make it configurable  
  Expected a `String`, default is still `config/i18n-js.yml`
- When running `rake i18n:js:export`, the `i18n.js` will also be exported to `I18n::JS.export_i18n_js_dir_path` by default
- Add `I18n::JS.export_i18n_js_dir_path`  
  Expected a `String`, default is `public/javascripts`  
  Set to `nil` will disable exporting `i18n.js`

### bug fixes

- Prevent toString() call on `undefined` when there is a missing interpolation value
- Added support for Rails instances without Sprockets object (https://github.com/fnando/i18n-js/pull/241)
- Fix `DEFAULT_OPTIONS` in `i18n.js` which contained an excessive comma
- Fix `nil` values are exported into JS files which causes strange translation error
- Fix pattern to replace all escaped $ in I18n.translate
- Fix JS `I18n.lookup` modifies existing locales accidentally

## 3.0.0.rc6

### enhancements

- You can now assign `I18n.locale` & `I18n.default_locale` before loading `i18n.js` in `application.html.*`
  (merged to `i18n-js-pika` already)
- You can include ERB in `config/i18n-js.yml`(https://github.com/fnando/i18n-js/pull/224)
- Add support for +00:00 style time zone designator (https://github.com/fnando/i18n-js/pull/167)
- Add back rake task for export (`rake i18n:js:export`)
- Not overriding translation when manually run `I18n::JS.export` (https://github.com/fnando/i18n-js/pull/171)
- Move missing placeholder text generation into its own function (for easier debugging) (https://github.com/fnando/i18n-js/pull/169)
- Add support for milliseconds (`lll` in `yyyy-mm-ddThh:mm:ss.lllZ`) (https://github.com/fnando/i18n-js/pull/192)
- Add back i18n-js.yml config file generator : `rails generate i18n:js:config` (https://github.com/fnando/i18n-js/pull/225)

### bug fixes

- `I18n::JS.export` no longer exports locales other than those in `I18n.available_locales`, if `I18n.available_locales` is set
- I18.t supports the base scope through the options argument
- I18.t accepts an array as the scope
- Fix regression: asset not being reloaded in development when translation changed
- Requires `i18n` to be `~> 0.6`, `0.5` does not work at all
- Fix using multi-star scope with top-level translation key (https://github.com/fnando/i18n-js/pull/221)


## Before 3.0.0.rc5

- Things happened.
