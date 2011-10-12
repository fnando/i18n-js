load("vendor/assets/javascripts/i18n.js");

describe("I18n.js", function(){
  before(function() {
    I18n.defaultLocale = "en";
    I18n.defaultSeparator = ".";
    I18n.locale = null;

    I18n.translations = {
      en: {
        hello: "Hello World!",
        greetings: {
          stranger: "Hello stranger!",
          name: "Hello {{name}}!"
        },
        profile: {
          details: "{{name}} is {{age}}-years old"
        },
        inbox: {
          one: "You have {{count}} message",
          other: "You have {{count}} messages",
          zero: "You have no messages"
        },
        unread: {
          one: "You have 1 new message ({{unread}} unread)",
          other: "You have {{count}} new messages ({{unread}} unread)",
          zero: "You have no new messages ({{unread}} unread)"
        },
        number: {
          human: {
            storage_units: {
              units: {
                "byte": {
                  one: "Byte",
                  other: "Bytes"
                },

                "kb": "KB",
                "mb": "MB",
                "gb": "GB",
                "tb": "TB"
              }
            }
          }
        }
      },

      "pt-BR": {
        hello: "Olá Mundo!",
        date: {
          formats: {
            "default": "%d/%m/%Y",
            "short": "%d de %B",
            "long": "%d de %B de %Y"
          },
            day_names: ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"],
            abbr_day_names: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"],
            month_names: [null, "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"],
            abbr_month_names: [null, "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"]
        },
        number: {
          percentage: {
            format: {
              delimiter: "",
              separator: ",",
              precision: 2
            }
          }
        },
        time: {
          formats: {
            "default": "%A, %d de %B de %Y, %H:%M h",
            "short": "%d/%m, %H:%M h",
            "long": "%A, %d de %B de %Y, %H:%M h"
          },
          am: "AM",
          pm: "PM"
        }
      },

      "en-US": {
        date: {
          formats: {
            "default": "%d/%m/%Y",
            "short": "%d de %B",
            "long": "%d de %B de %Y"
          },
            day_names: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
            abbr_day_names: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
            month_names: [null, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
            abbr_month_names: [null, "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"],
            meridian: ["am", "pm"]
        }
      }
    };
  });

  specify("with default options", function(){
    expect(I18n.defaultLocale).toBeEqualTo("en");
    expect(I18n.locale).toBeEqualTo(null);
    expect(I18n.currentLocale()).toBeEqualTo("en");
  });

  specify("with custom locale", function(){
    I18n.locale = "pt-BR";
    expect(I18n.currentLocale()).toBeEqualTo("pt-BR");
  });

  specify("aliases", function(){
    expect(I18n.t).toBe(I18n.translate);
    expect(I18n.l).toBe(I18n.localize);
    expect(I18n.p).toBe(I18n.pluralize);
  });

  specify("translation with single scope", function(){
    expect(I18n.t("hello")).toBeEqualTo("Hello World!");
  });

  specify("translation as object", function(){
    expect(I18n.t("greetings")).toBeInstanceOf(Object);
  });

  specify("translation with invalid scope shall not block", function(){
    actual = I18n.t("invalid.scope.shall.not.block");
    expected = '[missing "en.invalid.scope.shall.not.block" translation]';
    expect(actual).toBeEqualTo(expected);
  });

  specify("translation for single scope on a custom locale", function(){
    I18n.locale = "pt-BR";
    expect(I18n.t("hello")).toBeEqualTo("Olá Mundo!");
  });

  specify("translation for multiple scopes", function(){
    expect(I18n.t("greetings.stranger")).toBeEqualTo("Hello stranger!");
  });

  specify("translation with default locale option", function(){
    expect(I18n.t("hello", {locale: "en"})).toBeEqualTo("Hello World!");
    expect(I18n.t("hello", {locale: "pt-BR"})).toBeEqualTo("Olá Mundo!");
  });

  specify("translation should fall if locale is missing", function(){
    I18n.locale = "pt-BR";
    expect(I18n.t("greetings.stranger")).toBeEqualTo("[missing \"pt-BR.greetings.stranger\" translation]");
  });

  specify("translation should handle fallback if I18n.fallbacks == true", function(){
    I18n.locale = "pt-BR";
    I18n.fallbacks = true;
    expect(I18n.t("greetings.stranger")).toBeEqualTo("Hello stranger!");
  });

  specify("single interpolation", function(){
    actual = I18n.t("greetings.name", {name: "John Doe"});
    expect(actual).toBeEqualTo("Hello John Doe!");
  });

  specify("multiple interpolation", function(){
    actual = I18n.t("profile.details", {name: "John Doe", age: 27});
    expect(actual).toBeEqualTo("John Doe is 27-years old");
  });

  specify("translation with count option", function(){
    expect(I18n.t("inbox", {count: 0})).toBeEqualTo("You have no messages");
    expect(I18n.t("inbox", {count: 1})).toBeEqualTo("You have 1 message");
    expect(I18n.t("inbox", {count: 5})).toBeEqualTo("You have 5 messages");
  });

  specify("translation with count option and multiple placeholders", function(){
    actual = I18n.t("unread", {unread: 5, count: 1});
    expect(actual).toBeEqualTo("You have 1 new message (5 unread)");

    actual = I18n.t("unread", {unread: 2, count: 10});
    expect(actual).toBeEqualTo("You have 10 new messages (2 unread)");

    actual = I18n.t("unread", {unread: 5, count: 0});
    expect(actual).toBeEqualTo("You have no new messages (5 unread)");
  });

  specify("missing translation with count option", function(){
    actual = I18n.t("invalid", {count: 1});
    expect(actual).toBeEqualTo('[missing "en.invalid" translation]');

    I18n.translations.en.inbox.one = null;
    actual = I18n.t("inbox", {count: 1});
    expect(actual).toBeEqualTo('[missing "en.inbox.one" translation]');
  });

  specify("pluralization", function(){
    expect(I18n.p(0, "inbox")).toBeEqualTo("You have no messages");
    expect(I18n.p(1, "inbox")).toBeEqualTo("You have 1 message");
    expect(I18n.p(5, "inbox")).toBeEqualTo("You have 5 messages");
  });

  specify("pluralize should return 'other' scope", function(){
    I18n.translations["en"]["inbox"]["zero"] = null;
    expect(I18n.p(0, "inbox")).toBeEqualTo("You have 0 messages");
  });

  specify("pluralize should return 'zero' scope", function(){
    I18n.translations["en"]["inbox"]["zero"] = "No messages (zero)";
    I18n.translations["en"]["inbox"]["none"] = "No messages (none)";

    expect(I18n.p(0, "inbox")).toBeEqualTo("No messages (zero)");
  });

  specify("pluralize should return 'none' scope", function(){
    I18n.translations["en"]["inbox"]["zero"] = null;
    I18n.translations["en"]["inbox"]["none"] = "No messages (none)";

    expect(I18n.p(0, "inbox")).toBeEqualTo("No messages (none)");
  });

  specify("pluralize with negative values", function(){
    expect(I18n.p(-1, "inbox")).toBeEqualTo("You have -1 message");
    expect(I18n.p(-5, "inbox")).toBeEqualTo("You have -5 messages");
  });

  specify("pluralize with missing scope", function(){
    expect(I18n.p(-1, "missing")).toBeEqualTo('[missing "en.missing" translation]');
  });

  specify("pluralize with multiple placeholders", function(){
    actual = I18n.p(1, "unread", {unread: 5});
    expect(actual).toBeEqualTo("You have 1 new message (5 unread)");

    actual = I18n.p(10, "unread", {unread: 2});
    expect(actual).toBeEqualTo("You have 10 new messages (2 unread)");

    actual = I18n.p(0, "unread", {unread: 5});
    expect(actual).toBeEqualTo("You have no new messages (5 unread)");
  });

  specify("pluralize should allow empty strings", function(){
    I18n.translations["en"]["inbox"]["zero"] = "";

    expect(I18n.p(0, "inbox")).toBeEqualTo("");
  });

  specify("numbers with default settings", function(){
    expect(I18n.toNumber(1)).toBeEqualTo("1.000");
    expect(I18n.toNumber(12)).toBeEqualTo("12.000");
    expect(I18n.toNumber(123)).toBeEqualTo("123.000");
    expect(I18n.toNumber(1234)).toBeEqualTo("1,234.000");
    expect(I18n.toNumber(12345)).toBeEqualTo("12,345.000");
    expect(I18n.toNumber(123456)).toBeEqualTo("123,456.000");
    expect(I18n.toNumber(1234567)).toBeEqualTo("1,234,567.000");
    expect(I18n.toNumber(12345678)).toBeEqualTo("12,345,678.000");
    expect(I18n.toNumber(123456789)).toBeEqualTo("123,456,789.000");
  });

  specify("negative numbers with default settings", function(){
    expect(I18n.toNumber(-1)).toBeEqualTo("-1.000");
    expect(I18n.toNumber(-12)).toBeEqualTo("-12.000");
    expect(I18n.toNumber(-123)).toBeEqualTo("-123.000");
    expect(I18n.toNumber(-1234)).toBeEqualTo("-1,234.000");
    expect(I18n.toNumber(-12345)).toBeEqualTo("-12,345.000");
    expect(I18n.toNumber(-123456)).toBeEqualTo("-123,456.000");
    expect(I18n.toNumber(-1234567)).toBeEqualTo("-1,234,567.000");
    expect(I18n.toNumber(-12345678)).toBeEqualTo("-12,345,678.000");
    expect(I18n.toNumber(-123456789)).toBeEqualTo("-123,456,789.000");
  });

  specify("numbers with partial translation and default options", function(){
    I18n.translations.en.number = {
      format: {
        precision: 2
      }
    };

    expect(I18n.toNumber(1234)).toBeEqualTo("1,234.00");
  });

  specify("numbers with full translation and default options", function(){
    I18n.translations.en.number = {
      format: {
        delimiter: ".",
        separator: ",",
        precision: 2
      }
    };

    expect(I18n.toNumber(1234)).toBeEqualTo("1.234,00");
  });

  specify("numbers with some custom options that should be merged with default options", function(){
    expect(I18n.toNumber(1234, {precision: 0})).toBeEqualTo("1,234");
    expect(I18n.toNumber(1234, {separator: '-'})).toBeEqualTo("1,234-000");
    expect(I18n.toNumber(1234, {delimiter: '-'})).toBeEqualTo("1-234.000");
  });

  specify("numbers considering options", function(){
    options = {
      precision: 2,
      separator: ",",
      delimiter: "."
    };

    expect(I18n.toNumber(1, options)).toBeEqualTo("1,00");
    expect(I18n.toNumber(12, options)).toBeEqualTo("12,00");
    expect(I18n.toNumber(123, options)).toBeEqualTo("123,00");
    expect(I18n.toNumber(1234, options)).toBeEqualTo("1.234,00");
    expect(I18n.toNumber(123456, options)).toBeEqualTo("123.456,00");
    expect(I18n.toNumber(1234567, options)).toBeEqualTo("1.234.567,00");
    expect(I18n.toNumber(12345678, options)).toBeEqualTo("12.345.678,00");
  });

  specify("numbers with different precisions", function(){
    options = {separator: ".", delimiter: ","};

    options["precision"] = 2;
    expect(I18n.toNumber(1.98, options)).toBeEqualTo("1.98");

    options["precision"] = 3;
    expect(I18n.toNumber(1.98, options)).toBeEqualTo("1.980");

    options["precision"] = 2;
    expect(I18n.toNumber(1.987, options)).toBeEqualTo("1.99");

    options["precision"] = 1;
    expect(I18n.toNumber(1.98, options)).toBeEqualTo("2.0");

    options["precision"] = 0;
    expect(I18n.toNumber(1.98, options)).toBeEqualTo("2");
  });

  specify("currency with default settings", function(){
    expect(I18n.toCurrency(100.99)).toBeEqualTo("$100.99");
    expect(I18n.toCurrency(1000.99)).toBeEqualTo("$1,000.99");
  });

  specify("currency with custom settings", function(){
    I18n.translations.en.number = {
      currency: {
        format: {
          format: "%n %u",
          unit: "USD",
          delimiter: ".",
          separator: ",",
          precision: 2
        }
      }
    };

    expect(I18n.toCurrency(12)).toBeEqualTo("12,00 USD");
    expect(I18n.toCurrency(123)).toBeEqualTo("123,00 USD");
    expect(I18n.toCurrency(1234.56)).toBeEqualTo("1.234,56 USD");
  });

  specify("currency with custom settings and partial overriding", function(){
    I18n.translations.en.number = {
      currency: {
        format: {
          format: "%n %u",
          unit: "USD",
          delimiter: ".",
          separator: ",",
          precision: 2
        }
      }
    };

    expect(I18n.toCurrency(12, {precision: 0})).toBeEqualTo("12 USD");
    expect(I18n.toCurrency(123, {unit: "bucks"})).toBeEqualTo("123,00 bucks");
  });

  specify("currency with some custom options that should be merged with default options", function(){
    expect(I18n.toCurrency(1234, {precision: 0})).toBeEqualTo("$1,234");
    expect(I18n.toCurrency(1234, {unit: "º"})).toBeEqualTo("º1,234.00");
    expect(I18n.toCurrency(1234, {separator: "-"})).toBeEqualTo("$1,234-00");
    expect(I18n.toCurrency(1234, {delimiter: "-"})).toBeEqualTo("$1-234.00");
    expect(I18n.toCurrency(1234, {format: "%u %n"})).toBeEqualTo("$ 1,234.00");
  });

  specify("localize numbers", function(){
    expect(I18n.l("number", 1234567)).toBeEqualTo("1,234,567.000");
  });

  specify("localize currency", function(){
    expect(I18n.l("currency", 1234567)).toBeEqualTo("$1,234,567.00");
  });

  specify("parse date", function(){
    expected = new Date(2009, 0, 24, 0, 0, 0);
    actual = I18n.parseDate("2009-01-24");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(2009, 0, 24, 0, 15, 0);
    actual = I18n.parseDate("2009-01-24 00:15:00");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(2009, 0, 24, 0, 0, 15);
    actual = I18n.parseDate("2009-01-24 00:00:15");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(2009, 0, 24, 15, 33, 44);
    actual = I18n.parseDate("2009-01-24 15:33:44");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(2009, 0, 24, 0, 0, 0);
    actual = I18n.parseDate(expected.getTime());
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(2009, 0, 24, 0, 0, 0);
    actual = I18n.parseDate("01/24/2009");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(2009, 0, 24, 14, 33, 55);
    actual = I18n.parseDate(expected).toString();
    expect(actual).toBeEqualTo(expected.toString());

    expected = new Date(2009, 0, 24, 15, 33, 44);
    actual = I18n.parseDate("2009-01-24T15:33:44");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(Date.UTC(2011, 6, 20, 12, 51, 55));
    actual = I18n.parseDate("2011-07-20T12:51:55+0000");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(Date.UTC(2011, 6, 20, 13, 03, 39));
    actual = I18n.parseDate("Wed Jul 20 13:03:39 +0000 2011");
    expect(actual.toString()).toBeEqualTo(expected.toString());

    expected = new Date(Date.UTC(2009, 0, 24, 15, 33, 44));
    actual = I18n.parseDate("2009-01-24T15:33:44Z");
    expect(actual.toString()).toBeEqualTo(expected.toString());
  });

  specify("date formatting", function(){
    I18n.locale = "pt-BR";

    // 2009-04-26 19:35:44 (Sunday)
    var date = new Date(2009, 3, 26, 19, 35, 44);

    // short week day
    expect(I18n.strftime(date, "%a")).toBeEqualTo("Dom");

    // full week day
    expect(I18n.strftime(date, "%A")).toBeEqualTo("Domingo");

    // short month
    expect(I18n.strftime(date, "%b")).toBeEqualTo("Abr");

    // full month
    expect(I18n.strftime(date, "%B")).toBeEqualTo("Abril");

    // day
    expect(I18n.strftime(date, "%d")).toBeEqualTo("26");

    // 24-hour
    expect(I18n.strftime(date, "%H")).toBeEqualTo("19");

    // 12-hour
    expect(I18n.strftime(date, "%I")).toBeEqualTo("07");

    // month
    expect(I18n.strftime(date, "%m")).toBeEqualTo("04");

    // minutes
    expect(I18n.strftime(date, "%M")).toBeEqualTo("35");

    // meridian
    expect(I18n.strftime(date, "%p")).toBeEqualTo("PM");

    // seconds
    expect(I18n.strftime(date, "%S")).toBeEqualTo("44");

    // week day
    expect(I18n.strftime(date, "%w")).toBeEqualTo("0");

    // short year
    expect(I18n.strftime(date, "%y")).toBeEqualTo("09");

    // full year
    expect(I18n.strftime(date, "%Y")).toBeEqualTo("2009");
  });

  specify("date formatting without padding", function(){
    I18n.locale = "pt-BR";

    // 2009-04-26 19:35:44 (Sunday)
    var date = new Date(2009, 3, 9, 7, 8, 9);

    // 24-hour without padding
    expect(I18n.strftime(date, "%-H")).toBeEqualTo("7");

    // 12-hour without padding
    expect(I18n.strftime(date, "%-I")).toBeEqualTo("7");

    // minutes without padding
    expect(I18n.strftime(date, "%-M")).toBeEqualTo("8");

    // seconds without padding
    expect(I18n.strftime(date, "%-S")).toBeEqualTo("9");

    // short year without padding
    expect(I18n.strftime(date, "%-y")).toBeEqualTo("9");

    // month without padding
    expect(I18n.strftime(date, "%-m")).toBeEqualTo("4");

    // day without padding
    expect(I18n.strftime(date, "%-d")).toBeEqualTo("9");
    expect(I18n.strftime(date, "%e")).toBeEqualTo("9");
  });

  specify("date formatting with padding", function(){
    I18n.locale = "pt-BR";

    // 2009-04-26 19:35:44 (Sunday)
    var date = new Date(2009, 3, 9, 7, 8, 9);

    // 24-hour
    expect(I18n.strftime(date, "%H")).toBeEqualTo("07");

    // 12-hour
    expect(I18n.strftime(date, "%I")).toBeEqualTo("07");

    // minutes
    expect(I18n.strftime(date, "%M")).toBeEqualTo("08");

    // seconds
    expect(I18n.strftime(date, "%S")).toBeEqualTo("09");

    // short year
    expect(I18n.strftime(date, "%y")).toBeEqualTo("09");

    // month
    expect(I18n.strftime(date, "%m")).toBeEqualTo("04");

    // day
    expect(I18n.strftime(date, "%d")).toBeEqualTo("09");
  });

  specify("date formatting with negative time zone", function(){
    I18n.locale = "pt-BR";
    var date = new Date(2009, 3, 26, 19, 35, 44);
    stub(date, "getTimezoneOffset()", 345);

    expect(I18n.strftime(date, "%z")).toMatch(/^(\+|-)[\d]{4}$/);
    expect(I18n.strftime(date, "%z")).toBeEqualTo("-0545");
  });

  specify("date formatting with positive time zone", function(){
    I18n.locale = "pt-BR";
    var date = new Date(2009, 3, 26, 19, 35, 44);
    stub(date, "getTimezoneOffset()", -345);

    expect(I18n.strftime(date, "%z")).toMatch(/^(\+|-)[\d]{4}$/);
    expect(I18n.strftime(date, "%z")).toBeEqualTo("+0545");
  });

  specify("date formatting with custom meridian", function(){
    I18n.locale = "en-US";
    var date = new Date(2009, 3, 26, 19, 35, 44);
    expect(I18n.strftime(date, "%p")).toBeEqualTo("pm");
  });

  specify("date formatting meridian boundaries", function(){
    I18n.locale = "en-US";
    var date = new Date(2009, 3, 26, 0, 35, 44);
    expect(I18n.strftime(date, "%p")).toBeEqualTo("am");

    date = new Date(2009, 3, 26, 12, 35, 44);
    expect(I18n.strftime(date, "%p")).toBeEqualTo("pm");
  });

  specify("date formatting hour12 values", function(){
    I18n.locale = "pt-BR";
    var date = new Date(2009, 3, 26, 19, 35, 44);
    expect(I18n.strftime(date, "%I")).toBeEqualTo("07");

    date = new Date(2009, 3, 26, 12, 35, 44);
    expect(I18n.strftime(date, "%I")).toBeEqualTo("12");

    date = new Date(2009, 3, 26, 0, 35, 44);
    expect(I18n.strftime(date, "%I")).toBeEqualTo("12");
  });

  specify("localize date strings", function(){
    I18n.locale = "pt-BR";

    expect(I18n.l("date.formats.default", "2009-11-29")).toBeEqualTo("29/11/2009");
    expect(I18n.l("date.formats.short", "2009-01-07")).toBeEqualTo("07 de Janeiro");
    expect(I18n.l("date.formats.long", "2009-01-07")).toBeEqualTo("07 de Janeiro de 2009");
  });

  specify("localize time strings", function(){
    I18n.locale = "pt-BR";

    expect(I18n.l("time.formats.default", "2009-11-29 15:07:59")).toBeEqualTo("Domingo, 29 de Novembro de 2009, 15:07 h");
    expect(I18n.l("time.formats.short", "2009-01-07 09:12:35")).toBeEqualTo("07/01, 09:12 h");
    expect(I18n.l("time.formats.long", "2009-11-29 15:07:59")).toBeEqualTo("Domingo, 29 de Novembro de 2009, 15:07 h");
  });

  specify("localize percentage", function(){
    I18n.locale = "pt-BR";
    expect(I18n.l("percentage", 123.45)).toBeEqualTo("123,45%");
  });

  specify("default value for simple translation", function(){
    actual = I18n.t("warning", {defaultValue: "Warning!"});
    expect(actual).toBeEqualTo("Warning!");
  });

  specify("default value with interpolation", function(){
    actual = I18n.t(
      "alert",
      {defaultValue: "Attention! {{message}}", message: "You're out of quota!"}
    );

    expect(actual).toBeEqualTo("Attention! You're out of quota!");
  });

  specify("default value should not be used when scope exist", function(){
    actual = I18n.t("hello", {defaultValue: "What's up?"});
    expect(actual).toBeEqualTo("Hello World!");
  });

  specify("default value for pluralize", function(){
    options = {defaultValue: {
      none: "No things here!",
      one: "There is {{count}} thing here!",
      other: "There are {{count}} things here!"
    }};

    expect(I18n.p(0, "things", options)).toBeEqualTo("No things here!");
    expect(I18n.p(1, "things", options)).toBeEqualTo("There is 1 thing here!");
    expect(I18n.p(5, "things", options)).toBeEqualTo("There are 5 things here!");
  });

  specify("default value for pluralize should not be used when scope exist", function(){
    options = {defaultValue: {
      none: "No things here!",
      one: "There is {{count}} thing here!",
      other: "There are {{count}} things here!"
    }};

    expect(I18n.pluralize(0, "inbox", options)).toBeEqualTo("You have no messages");
    expect(I18n.pluralize(1, "inbox", options)).toBeEqualTo("You have 1 message");
    expect(I18n.pluralize(5, "inbox", options)).toBeEqualTo("You have 5 messages");
  });

  specify("prepare options", function(){
    options = I18n.prepareOptions(
      {name: "Mary Doe"},
      {name: "John Doe", role: "user"}
    );

    expect(options["name"]).toBeEqualTo("Mary Doe");
    expect(options["role"]).toBeEqualTo("user");
  });

  specify("prepare options with multiple options", function(){
    options = I18n.prepareOptions(
      {name: "Mary Doe"},
      {name: "John Doe", role: "user"},
      {age: 33},
      {email: "mary@doe.com", url: "http://marydoe.com"},
      {role: "admin", email: "john@doe.com"}
    );

    expect(options["name"]).toBeEqualTo("Mary Doe");
    expect(options["role"]).toBeEqualTo("user");
    expect(options["age"]).toBeEqualTo(33);
    expect(options["email"]).toBeEqualTo("mary@doe.com");
    expect(options["url"]).toBeEqualTo("http://marydoe.com");
  });

  specify("prepare options should return an empty hash when values are null", function(){
    expect({}).toBeEqualTo(I18n.prepareOptions(null, null));
  });

  specify("percentage with defaults", function(){
    expect(I18n.toPercentage(1234)).toBeEqualTo("1234.000%");
  });

  specify("percentage with custom options", function(){
    actual = I18n.toPercentage(1234, {delimiter: "_", precision: 0});
    expect(actual).toBeEqualTo("1_234%");
  });

  specify("percentage with translation", function(){
    I18n.translations.en.number = {
      percentage: {
        format: {
          precision: 2,
          delimiter: ".",
          separator: ","
        }
      }
    };

    expect(I18n.toPercentage(1234)).toBeEqualTo("1.234,00%");
  });

  specify("percentage with translation and custom options", function(){
    I18n.translations.en.number = {
      percentage: {
        format: {
          precision: 2,
          delimiter: ".",
          separator: ","
        }
      }
    };

    actual = I18n.toPercentage(1234, {precision: 4, delimiter: "-", separator: "+"});
    expect(actual).toBeEqualTo("1-234+0000%");
  });

  specify("scope option as string", function(){
    actual = I18n.t("stranger", {scope: "greetings"});
    expect(actual).toBeEqualTo("Hello stranger!");
  });

  specify("scope as array", function(){
    actual = I18n.t(["greetings", "stranger"]);
    expect(actual).toBeEqualTo("Hello stranger!");
  });

  specify("new placeholder syntax", function(){
    I18n.translations["en"]["new_syntax"] = "Hi %{name}!";
    actual = I18n.t("new_syntax", {name: "John"});
    expect(actual).toBeEqualTo("Hi John!");
  });

  specify("return translation for custom scope separator", function(){
    I18n.defaultSeparator = "•";
    actual = I18n.t("greetings•stranger");
    expect(actual).toBeEqualTo("Hello stranger!");
  });

  specify("return number as human size", function(){
    kb = 1024;

    expect(I18n.toHumanSize(1)).toBeEqualTo("1Byte");
    expect(I18n.toHumanSize(100)).toBeEqualTo("100Bytes");

    expect(I18n.toHumanSize(kb)).toBeEqualTo("1KB");
    expect(I18n.toHumanSize(kb * 1.5)).toBeEqualTo("1.5KB");

    expect(I18n.toHumanSize(kb * kb)).toBeEqualTo("1MB");
    expect(I18n.toHumanSize(kb * kb * 1.5)).toBeEqualTo("1.5MB");

    expect(I18n.toHumanSize(kb * kb * kb)).toBeEqualTo("1GB");
    expect(I18n.toHumanSize(kb * kb * kb * 1.5)).toBeEqualTo("1.5GB");

    expect(I18n.toHumanSize(kb * kb * kb * kb)).toBeEqualTo("1TB");
    expect(I18n.toHumanSize(kb * kb * kb * kb * 1.5)).toBeEqualTo("1.5TB");

    expect(I18n.toHumanSize(kb * kb * kb * kb * kb)).toBeEqualTo("1024TB");
  });

  specify("return number as human size using custom options", function(){
    expect(I18n.toHumanSize(1024 * 1.6, {precision: 0})).toBeEqualTo("2KB");
  });

  specify("return number without insignificant zeros", function(){
    options = {precision: 4, strip_insignificant_zeros: true};

    expect(I18n.toNumber(65, options)).toBeEqualTo("65");
    expect(I18n.toNumber(1.2, options)).toBeEqualTo("1.2");
    expect(I18n.toCurrency(1.2, options)).toBeEqualTo("$1.2");
    expect(I18n.toHumanSize(1.2, options)).toBeEqualTo("1.2Bytes");
  });
});
