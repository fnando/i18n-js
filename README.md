# I18n.js

[![Build Status](https://travis-ci.org/fnando/i18n-js.svg?branch=master)](https://travis-ci.org/fnando/i18n-js)
[![Code Climate](https://codeclimate.com/github/fnando/i18n-js.png)](https://codeclimate.com/github/fnando/i18n-js)

It's a small library to provide the Rails I18n translations on the JavaScript.

Features:

- Pluralization
- Date/Time localization
- Number localization
- Locale fallback
- Asset pipeline support
- Lots more! :)

## Usage

### Installation

#### Rails app

Add the gem to your Gemfile.

    source "https://rubygems.org"
    gem "rails", "3.2.3"
    gem "i18n-js"

#### Rails app with [Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html)

If you're using the [asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html),
then you must add the following line to your `app/assets/javascripts/application.js`.

```javascript
//
// This is optional (in case you have `I18n is not defined` error)
// If you want to put this line, you must put it BEFORE `i18n/translations`
//= require i18n
//
// This is a must
//= require i18n/translations
```

#### Rails app without [Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html)

If you're not using the asset pipeline, download the JavaScript file at
<https://github.com/fnando/i18n-js/blob/master/app/assets/javascripts/i18n.js> and load it on your page.
Also load the `translations.js` file.

```erb
<%# This is just an example, you can put `i18n.js` and `translations.js` anywhere you like %>
<%# Unlike the Asset Pipeline example, you need to require both **in order** %>
<%= javascript_include_tag "i18n" %>
<%= javascript_include_tag "translations" %>
```

This `translations.js` file can be automatically generated by the `I18n::JS::Middleware`.
Just add it to your `config/application.rb` file.
Don't add this middleware if you are using [asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html)!

    config.middleware.use I18n::JS::Middleware

If you can't generate this file in production (Heroku anyone?), you can "precompile"
it by running the following command. Move the middleware line to your
`config/environments/development.rb` file and run the following command before
deploying.

    $ rake i18n:js:export

This will export all translation files, including the custom scopes you may have
defined on `config/i18n-js.yml`. If `I18n.available_locales` is set (e.g. in your
Rails `config/application.rb` file) then only the specified locales will be exported.

#### Export Configuration

Exported translation files generated by `I18n::JS::Middleware` or `rake i18n:js:export` can be customized with config file `config/i18n-js.yml` (use `rails generate i18n:js:config` to create it). You can even get more files generated to different folders and with different translations to best suit your needs. But this does not affect anything if you use Asset Pipeline.

Examples:
```yaml
translations:
- file: 'public/javascripts/path-to-your-messages-file.js'
  only: '*.date.formats'
- file: 'public/javascripts/path-to-your-second-file.js'
  only: ['*.activerecord', '*.admin.*.title']
```

If `only` is omitted all the translations will be saved. Also, make sure you add that initial `*`; it specifies that all languages will be exported. If you want to export only one language, you can do something like this:
```yaml
translations:
- file: 'public/javascripts/en.js'
  only: 'en.*'
- file: 'public/javascripts/pt-BR.js'
  only: 'pt-BR.*'
```

Optionally, you can auto generate a translation file per available locale if you specify the `%{locale}` placeholder.
```yaml
translations:
- file: "public/javascripts/i18n/%{locale}.js"
  only: '*'
- file: "public/javascripts/frontend/i18n/%{locale}.js"
  only: ['frontend', 'users']
```

You can also include ERB in your config file.
```yaml
translations:
<% Widgets.each do |widget| %>
- file: <%= "'#{widget.file}'" %>
  only: <%= "'#{widget.only}'" %>
<% end %>
```

To find more examples on how to use the configuration file please refer to the tests.

#### Vanilla JavaScript

Just add the `i18n.js` file to your page. You'll have to build the translations object
by hand or using your favorite programming language. More info below.

### Setting up

You **don't** need to set up a thing. The default settings will work just okay. But if you want to split translations into several files or specify specific contexts, you can follow the rest of this setting up section.

Set your locale is easy as
```javascript
I18n.defaultLocale = "pt-BR";
I18n.locale = "pt-BR";
I18n.currentLocale();
// pt-BR
```

**NOTE:** You can now apply your configuration **before I18n** is loaded like this:
```javascript
I18n = {} // You must define this object in top namespace, which should be `window`
I18n.defaultLocale = "pt-BR";
I18n.locale = "pt-BR";

// Load I18n from `i18n.js`, `application.js` or whatever

I18n.currentLocale();
// pt-BR
```

In practice, you'll have something like the following in your `application.html.erb`:

    <script type="text/javascript">
      I18n.defaultLocale = "<%= I18n.default_locale %>";
      I18n.locale = "<%= I18n.locale %>";
    </script>

You can use translate your messages:

    I18n.t("some.scoped.translation");
    // or translate with explicit setting of locale
    I18n.t("some.scoped.translation", {locale: "fr"});

You can also interpolate values:

    I18n.t("hello", {name: "John Doe"});

You can set default values for missing scopes:

    // simple translation
    I18n.t("some.missing.scope", {defaultValue: "A default message"});

    // with interpolation
    I18n.t("noun", {defaultValue: "I'm a {{noun}}", noun: "Mac"});

You can also provide a list of default fallbacks for missing scopes:

    // As a scope
    I18n.t("some.missing.scope", {defaults: [{scope: "some.existing.scope"}]});

    // As a simple translation
    I18n.t("some.missing.scope", {defaults: [{message: "some.existing.scope"}]});

    Default values must be provided as an array of hashs where the key is the
    type of translation desired, a `scope` or a `message`. The translation returned
    will be either the first scope recognized, or the first message defined.

    The translation will fallback to the `defaultValue` translation if no scope
    in `defaults` matches and if no default of type `message` is found.

Translation fallback can be enabled by enabling the `I18n.fallbacks` option:

    <script type="text/javascript">
      I18n.fallbacks = true;
    </script>

By default missing translations will first be looked for in less
specific versions of the requested locale and if that fails by taking
them from your `I18n.defaultLocale`.

    // if I18n.defaultLocale = "en" and translation doesn't exist
    // for I18n.locale = "de-DE" this key will be taken from "de" locale scope
    // or, if that also doesn't exist, from "en" locale scope
    I18n.t("some.missing.scope");

Custom fallback rules can also be specified for a particular language. There
are three different ways of doing it so:

    I18n.locales.no = ["nb", "en"];
    I18n.locales.no = "nb";
    I18n.locales.no = function(locale){ return ["nb"]; };

Pluralization is possible as well and by default provides English rules:

    I18n.t("inbox.counting", {count: 10}); // You have 10 messages

The sample above expects the following translation:

    en:
      inbox:
        counting:
          one: You have 1 new message
          other: You have {{count}} new messages
          zero: You have no messages

**NOTE:** Rails I18n recognizes the `zero` option.

If you need special rules just define them for your language, for example Russian, just add a new pluralizer:

    I18n.pluralization["ru"] = function (count) {
      var key = count % 10 == 1 && count % 100 != 11 ? "one" : [2, 3, 4].indexOf(count % 10) >= 0 && [12, 13, 14].indexOf(count % 100) < 0 ? "few" : count % 10 == 0 || [5, 6, 7, 8, 9].indexOf(count % 10) >= 0 || [11, 12, 13, 14].indexOf(count % 100) >= 0 ? "many" : "other";
      return [key];
    };

You can find all rules on <http://unicode.org/repos/cldr-tmp/trunk/diff/supplemental/language_plural_rules.html>.

If you're using the same scope over and over again, you may use the `scope` option.

    var options = {scope: "activerecord.attributes.user"};

    I18n.t("name", options);
    I18n.t("email", options);
    I18n.t("username", options);

You can also provide an array as scope.

    // use the greetings.hello scope
    I18n.t(["greetings", "hello"]);

#### Number formatting

Similar to Rails helpers, you have localized number and currency formatting.

    I18n.l("currency", 1990.99);
    // $1,990.99

    I18n.l("number", 1990.99);
    // 1,990.99

    I18n.l("percentage", 123.45);
    // 123.450%

To have more control over number formatting, you can use the
`I18n.toNumber`, `I18n.toPercentage`, `I18n.toCurrency` and `I18n.toHumanSize`
functions.

    I18n.toNumber(1000);     // 1,000.000
    I18n.toCurrency(1000);   // $1,000.00
    I18n.toPercentage(100);  // 100.000%

The `toNumber` and `toPercentage` functions accept the following options:

- `precision`: defaults to `3`
- `separator`: defaults to `.`
- `delimiter`: defaults to `,`
- `strip_insignificant_zeros`: defaults to `false`

See some number formatting examples:

    I18n.toNumber(1000, {precision: 0});                   // 1,000
    I18n.toNumber(1000, {delimiter: ".", separator: ","}); // 1.000,000
    I18n.toNumber(1000, {delimiter: ".", precision: 0});   // 1.000

The `toCurrency` function accepts the following options:

- `precision`: sets the level of precision
- `separator`: sets the separator between the units
- `delimiter`: sets the thousands delimiter
- `format`: sets the format of the output string
- `unit`: sets the denomination of the currency
- `strip_insignificant_zeros`: defaults to `false`

You can provide only the options you want to override:

    I18n.toCurrency(1000, {precision: 0}); // $1,000

The `toHumanSize` function accepts the following options:

- `precision`: defaults to `1`
- `separator`: defaults to `.`
- `delimiter`: defaults to `""`
- `strip_insignificant_zeros`: defaults to `false`
- `format`: defaults to `%n%u`

<!---->

    I18n.toHumanSize(1234); // 1KB
    I18n.toHumanSize(1234 * 1024); // 1MB

#### Date formatting

    // accepted formats
    I18n.l("date.formats.short", "2009-09-18");           // yyyy-mm-dd
    I18n.l("time.formats.short", "2009-09-18 23:12:43");  // yyyy-mm-dd hh:mm:ss
    I18n.l("time.formats.short", "2009-11-09T18:10:34");  // JSON format with local Timezone (part of ISO-8601)
    I18n.l("time.formats.short", "2009-11-09T18:10:34Z"); // JSON format in UTC (part of ISO-8601)
    I18n.l("date.formats.short", 1251862029000);          // Epoch time
    I18n.l("date.formats.short", "09/18/2009");           // mm/dd/yyyy
    I18n.l("date.formats.short", (new Date()));           // Date object

If you prefer, you can use the `I18n.strftime` function to format dates.

    var date = new Date();
    I18n.strftime(date, "%d/%m/%Y");

The accepted formats are:

    %a  - The abbreviated weekday name (Sun)
    %A  - The full weekday name (Sunday)
    %b  - The abbreviated month name (Jan)
    %B  - The full month name (January)
    %d  - Day of the month (01..31)
    %-d - Day of the month (1..31)
    %H  - Hour of the day, 24-hour clock (00..23)
    %-H - Hour of the day, 24-hour clock (0..23)
    %I  - Hour of the day, 12-hour clock (01..12)
    %-I - Hour of the day, 12-hour clock (1..12)
    %m  - Month of the year (01..12)
    %-m - Month of the year (1..12)
    %M  - Minute of the hour (00..59)
    %-M - Minute of the hour (0..59)
    %p  - Meridian indicator (AM  or  PM)
    %S  - Second of the minute (00..60)
    %-S - Second of the minute (0..60)
    %w  - Day of the week (Sunday is 0, 0..6)
    %y  - Year without a century (00..99)
    %-y - Year without a century (0..99)
    %Y  - Year with century
    %z  - Timezone offset (+0545)

Check out `spec/*.spec.js` files for more examples!

## Using I18n.js with other languages (Python, PHP, ...)

The JavaScript library is language agnostic; so you can use it with PHP, Python, [your favorite language here].
The only requirement is that you need to set the `translations` attribute like following:

    I18n.translations = {};

    I18n.translations["en"] = {
      message: "Some special message for you"
    }

    I18n.translations["pt-BR"] = {
      message: "Uma mensagem especial para você"
    }

## Known Issues

### Missing translations in precompiled file(s) after adding any new locale file

Due to the design of `sprockets`:
- `depend_on` only takes file paths, not directory paths
- registered `preprocessors` are only run when fingerprint of any asset file, including `.erb` files, is changed

New locale files won't be picked up unless any existing locale file content is changed.  
You can workaround it manually by running
```bash
$ rake assets:clobber
```
to clear the asset cache.  
**Or**  
Change something in existing locale file.  
**Or**  
Change `config.assets.version`  

**Note:** `rake assets:clobber` will also remove all fingerprinted assets.  
If you are precompiling assets on target machine(s),
old assets might be removed and cannot be served in cached pages.

Please see issue #213 for detail & related discussion.


## Maintainer

- Nando Vieira - <http://nandovieira.com.br>

## Contributing

Once you've made your great commits:

1. [Fork](http://help.github.com/forking/) I18n.js
2. Create a branch with a clear name
3. Make your changes (Please also add/change spec, README and CHANGELOG if applicable)
4. Push changes to the created branch
5. [Create an Pull Request](http://github.com/fnando/i18n-js/pulls)
6. That's it!

Please respect the indentation rules and code style.
And use 2 spaces, not tabs. And don't touch the versioning thing.

## Running tests

You can run I18n tests using Node.js or your browser.

To use Node.js, install the `jasmine-node` library:

    $ npm install jasmine-node

Then execute the following command from the lib's root directory:

    $ npm test

To run using your browser, just open the `spec/js/specs.html` file.

You can run both Ruby and JavaScript specs with `rake spec`.

## License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
