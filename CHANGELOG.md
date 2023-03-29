# Changelog

<!--
Prefix your message with one of the following:

- [Added] for new features.
- [Changed] for changes in existing functionality.
- [Deprecated] for soon-to-be removed features.
- [Removed] for now removed features.
- [Fixed] for any bug fixes.
- [Security] in case of vulnerabilities.
-->

## v4.2.3 - Mar 29, 2023

- [Fixed] Load plugins when running `i18n lint:*` commands.

## v4.2.2 - Dec 30, 2022

- [Changed] Do not re-export files whose contents haven't changed.
- [Changed] Translations will always be deep sorted.
- [Fixed] Remove procs from translations before exporting files.

## v4.2.1 - Dec 25, 2022

- [Changed] Change plugin api to be based on instance methods. This avoids
  having to pass in the config for each and every method. It also allows us
  adding helper methods to the base class.
- [Fixed] Fix performance issues with embed fallback translations' initial
  implementation.

## v4.2.0 - Dec 10, 2022

- [Added] Add `I18nJS::Plugin.after_export(files:, config:)` method, that's
  called whenever whenever I18nJS finishes exporting files. You can use it to
  further process files, or generate new files based on the exported files.
- [Added] Bult-in plugin `I18nJS::ExportFilesPlugin`, which allows exporting
  files out of the translations file by using a custom template.

## v4.1.0 - Dec 09, 2022

- [Added] Parse configuration files as erb.
- [Changed] `I18n.listen(run_on_start:)` was added to control if files should be
  exported during `I18n.listen`'s boot. The default value is `true`.
- [Added] Now it's possible to transform translations before exporting them
  using a stable plugin api.
- [Added] Built-in plugin `I18nJS::EmbedFallbackTranslationsPlugin`, which
  allows embedding missing translations on exported files.
- [Deprecated] The `i18n check` has been deprecated. Use
  `i18n lint:translations` instead.
- [Added] Use `i18n lint:scripts` to lint JavaScript/TypeScript.
- [Fixed] Expand paths passed to `I18nJS.listen(locales_dir:)`.

## v4.0.1 - Aug 25, 2022

- [Fixed] Shell out export to avoid handling I18n reloading heuristics.
- [Changed] `I18nJS.listen` now accepts a directories list to watch.
- [Changed] `I18nJS.listen` now accepts
  [listen](https://rubygems.org/gems/listen) options via `:options`.

## v4.0.0 - Jul 29, 2022

- Official release of i18n-js v4.0.0.
