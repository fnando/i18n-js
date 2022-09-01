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

## Unreleased

- [Changed] `I18n.listen(run_on_start:)` was added to control if files should be
  exported during `I18n.listen`'s boot. The default value is `true`.

## v4.0.1

- [Fixed] Shell out export to avoid handling I18n reloading heuristics.
- [Changed] `I18nJS.listen` now accepts a directories list to watch.
- [Changed] `I18nJS.listen` now accepts
  [listen](https://rubygems.org/gems/listen) options via `:options`.

## Jul 29, 2022

- Official release of i18n-js v4.0.0.
