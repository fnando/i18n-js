
## Unreleased

### bug fixes

- Prevent toString() call on `undefined` when there is a missing interpolation value
- Added support for Rails instances without Sprockets object (https://github.com/fnando/i18n-js/pull/241)
- Fix `DEFAULT_OPTIONS` in `i18n.js` which contained an excessive comma

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
- Add fallbacks option to i18n-js.yml (https://github.com/fnando/i18n-js/pull/226)

### bug fixes

- `I18n::JS.export` no longer exports locales other than those in `I18n.available_locales`, if `I18n.available_locales` is set
- I18.t supports the base scope through the options argument
- I18.t accepts an array as the scope
- Fix regression: asset not being reloaded in development when translation changed
- Requires `i18n` to be `~> 0.6`, `0.5` does not work at all
- Fix using multi-star scope with top-level translation key (https://github.com/fnando/i18n-js/pull/221)


## Before 3.0.0.rc5

- Things happened.
