new Test.Unit.Runner({
	setup: function() {
		I18n.defaultLocale = "en";
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
					none: "You have no messages"
				},
				unread: {
					one: "You have 1 new message ({{unread}} unread)",
					other: "You have {{count}} new messages ({{unread}} unread)",
					none: "You have no new messages ({{unread}} unread)"
				}
			},

			pt: {
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
				time: {
					formats: {
						"default": "%A, %d de %B de %Y, %H:%M h",
						"short": "%d/%m, %H:%M h",
						"long": "%A, %d de %B de %Y, %H:%M h"
					},
					am: "AM",
					pm: "PM"
				}
			}
		}
	},
	
	teardown: function() {
	},
	
	// Defaults
	testDefaults: function() { with(this) {
		assertEqual("en", I18n.defaultLocale);
		assertEqual(null, I18n.locale);
		assertEqual("en", I18n.currentLocale());
	}},
	
	// Custom locale
	testCustomLocale: function() { with(this) {
		I18n.locale = "pt";
		assertEqual("pt", I18n.currentLocale());
	}},
	
	// Aliases methods
	testAliasesMethods: function() { with(this) {
		assertEqual(I18n.translate, I18n.t);
		assertEqual(I18n.localize, I18n.l);
	}},
	
	// Translation for single scope
	testTranslationForSingleScope: function() { with(this) {
		assertEqual("Hello World!", I18n.translate("hello"));
	}},
	
	// Translation with invalid scope shall not block
	testTranslationWithInvalidScope: function() { with(this) {
		assertEqual("invalid.scope.shall.not.block", I18n.translate("invalid.scope.shall.not.block"));
	}},

	// Translation for single scope on a custom locale
	testTranslationForSingleScopeOnACustomLocale: function() { with(this) {
		I18n.locale = "pt";
		assertEqual("Olá Mundo!", I18n.translate("hello"));
	}},

	// Translation for multiple scopes
	testTranslationForMultipleScopes: function() { with(this) {
		assertEqual("Hello stranger!", I18n.translate("greetings.stranger"));
	}},
	
	// Single interpolation
	testSingleInterpolation: function() { with(this) {
		actual = I18n.translate("greetings.name", {name: "John Doe"});
		assertEqual("Hello John Doe!", actual);
	}},
	
	// Multiple interpolations
	testMultipleInterpolations: function() { with(this) {
		actual = I18n.translate("profile.details", {name: "John Doe", age: 27});
		assertEqual("John Doe is 27-years old", actual);
	}},
	
	// Pluralization
	testPluralization: function() { with(this) {
		assertEqual("You have 1 message", I18n.pluralize(1, "inbox"));
		assertEqual("You have 5 messages", I18n.pluralize(5, "inbox"));
		assertEqual("You have no messages", I18n.pluralize(0, "inbox"));
	}},
	
	// Pluralize should return "other" scope
	testPlurationShouldReturnOtherScope: function() { with(this) {
		I18n.translations["en"]["inbox"]["none"] = null;
		assertEqual("You have 0 messages", I18n.pluralize(0, "inbox"));
	}},
	
	// Pluralize with negative values
	testPluralizeWithNegativeValues: function() { with(this) {
		assertEqual("You have -1 message", I18n.pluralize(-1, "inbox"));
		assertEqual("You have -5 messages", I18n.pluralize(-5, "inbox"));
	}},
	
	// Pluralize with multiple placeholders
	testPluralizeWithMultiplePlaceholders: function() { with(this) {
		actual = I18n.pluralize(1, "unread", {unread: 5});
		assertEqual("You have 1 new message (5 unread)", actual);
		
		actual = I18n.pluralize(10, "unread", {unread: 2});
		assertEqual("You have 10 new messages (2 unread)", actual);
		
		actual = I18n.pluralize(0, "unread", {unread: 5});
		assertEqual("You have no new messages (5 unread)", actual);
	}},
	
	// Numbers considering options
	testNumbersConsideringOptions: function() { with(this) {
		options = {
			precision: 2,
			separator: ",",
			delimiter: "."
		};
		
		assertEqual("1.00", I18n.toNumber(1, options));
		assertEqual("12.00", I18n.toNumber(12, options));
		assertEqual("123.00", I18n.toNumber(123, options));
		assertEqual("1,234.00", I18n.toNumber(1234, options));
		assertEqual("123,456.00", I18n.toNumber(123456, options));
		assertEqual("1,234,567.00", I18n.toNumber(1234567, options));
		assertEqual("12,345,678.00", I18n.toNumber(12345678, options));
	}},

	// Numbers with different precisions
	testNumbersWithDifferentPrecisions: function() { with(this) {
		options = {separator: ",", delimiter: "."};
		
		options["precision"] = 2;
		assertEqual("1.98", I18n.toNumber(1.98, options));
		
		options["precision"] = 3;
		assertEqual("1.980", I18n.toNumber(1.98, options));
		
		options["precision"] = 3;
		assertEqual("1.980", I18n.toNumber(1.98, options));
		
		options["precision"] = 2;
		assertEqual("1.99", I18n.toNumber(1.987, options));
		
		options["precision"] = 1;
		assertEqual("2.0", I18n.toNumber(1.98, options));
	}},
	
	// Currency with default settings
	testCurrencyWithDefaultSettings: function() { with(this) {
		assertEqual("$100.99", I18n.toCurrency(100.99));
		assertEqual("$1,000.99", I18n.toCurrency(1000.99));
	}},
	
	// Current with custom settings
	testCurrentWithCustomSettings: function() { with(this) {
		I18n.translations["en"] = {
			number: {
				currency: {
					format: {
						format: "%n %u",
						unit: "USD",
						delimiter: ",",
						separator: ".",
						precision: 2
					}
				}
			}
		};
		
		assertEqual("12,00 USD", I18n.toCurrency(12));
		assertEqual("123,00 USD", I18n.toCurrency(123));
		assertEqual("1.234,56 USD", I18n.toCurrency(1234.56));
	}},

	// Localize numbers
	testLocalizeNumbers: function() { with(this) {
		assertEqual("1,234,567.00", I18n.localize("number", 1234567));
	}},

	// Localize currency
	testLocalizeCurrency: function() { with(this) {
		assertEqual("$1,234,567.00", I18n.localize("currency", 1234567));
	}},
	
	// Parse date
	testParseDate: function() { with(this) {
		expected = new Date(2009, 0, 24, 0, 0, 0);
		assertEqual(expected.toString(), I18n.parseDate("2009-01-24").toString());
		
		expected = new Date(2009, 0, 24, 15, 33, 44);
		assertEqual(expected.toString(), I18n.parseDate("2009-01-24 15:33:44").toString());
		
		expected = new Date(2009, 0, 24, 0, 0, 0);
		assertEqual(expected.toString(), I18n.parseDate(expected.getTime()).toString());
		
		expected = new Date(2009, 0, 24, 0, 0, 0);
		assertEqual(expected.toString(), I18n.parseDate("01/24/2009").toString());
		
		expected = new Date(2009, 0, 24, 14, 33, 55);
		assertEqual(expected.toString(), I18n.parseDate(expected).toString());

		expected = new Date(2009, 0, 24, 15, 33, 44);
		assertEqual(expected.toString(), I18n.parseDate("2009-01-24T15:33:44").toString());

		expected = new Date(Date.UTC(2009, 0, 24, 15, 33, 44));
		assertEqual(expected.toString(), I18n.parseDate("2009-01-24T15:33:44Z").toString());
	}},
	
	// Date formatting
	testDateFormatting: function() { with(this) {
		I18n.locale = "pt";
		
		// 2009-04-26 19:35:44 (Sunday)
		var date = new Date(2009, 3, 26, 19, 35, 44);
		
		// short week day
		assertEqual("Dom", I18n.strftime(date, "%a"));
		
		// full week day
		assertEqual("Domingo", I18n.strftime(date, "%A"));
		
		// short month
		assertEqual("Abr", I18n.strftime(date, "%b"));
		
		// full month
		assertEqual("Abril", I18n.strftime(date, "%B"));
		
		// short week day
		assertEqual("26", I18n.strftime(date, "%d"));
		
		// 24-hour
		assertEqual("19", I18n.strftime(date, "%H"));
		
		// 12-hour
		assertEqual("7", I18n.strftime(date, "%I"));
		
		// month
		assertEqual("04", I18n.strftime(date, "%m"));
		
		// minutes
		assertEqual("35", I18n.strftime(date, "%M"));
		
		// meridian
		assertEqual("PM", I18n.strftime(date, "%p"));
		
		// seconds
		assertEqual("44", I18n.strftime(date, "%S"));
		
		// week day
		assertEqual("0", I18n.strftime(date, "%w"));
		
		// short year
		assertEqual("09", I18n.strftime(date, "%y"));
		
		// full year
		assertEqual("2009", I18n.strftime(date, "%Y"));
	}},

	// Date formatting with negative Timezone
	testDateFormattingWithNegativeTimezone: function() { with(this) {
		I18n.locale = "pt";
		
		var date = new Date(2009, 3, 26, 19, 35, 44);
		
		date.getTimezoneOffset = function() {
			return 345;
		};
		
		assertMatch(/^(\+|-)[\d]{4}$/, I18n.strftime(date, "%z"));
		assertEqual("-0545", I18n.strftime(date, "%z"));
	}},
	
	// Date formatting with positive Timezone
	testDateFormattingWithPositiveTimezone: function() { with(this) {
		I18n.locale = "pt";
		
		var date = new Date(2009, 3, 26, 19, 35, 44);
		
		date.getTimezoneOffset = function() {
			return -345;
		};
		
		assertMatch(/^(\+|-)[\d]{4}$/, I18n.strftime(date, "%z"));
		assertEqual("+0545", I18n.strftime(date, "%z"));
	}},
	
	// Localize date strings
	testLocalizeDateStrings: function() { with(this) {
		I18n.locale = "pt";
		
		assertEqual("29/11/2009", I18n.localize("date.formats.default", "2009-11-29"));
		assertEqual("07 de Janeiro", I18n.localize("date.formats.short", "2009-01-07"));
		assertEqual("07 de Janeiro de 2009", I18n.localize("date.formats.long", "2009-01-07"));
	}},	
	
	// Localize time strings
	testLocalizeTimeStrings: function() { with(this) {
		I18n.locale = "pt";
		assertEqual("Domingo, 29 de Novembro de 2009, 15:07 h", I18n.localize("time.formats.default", "2009-11-29 15:07:59"));
		assertEqual("07/01, 09:12 h", I18n.localize("time.formats.short", "2009-01-07 09:12:35"));
		assertEqual("Domingo, 29 de Novembro de 2009, 15:07 h", I18n.localize("time.formats.long", "2009-11-29 15:07:59"));
	}},
	
	// Default value for simple translation
	testDefaultValueForSimpleTranslation: function() { with(this) {
		actual = I18n.translate("warning", {defaultValue: "Warning!"});
		assertEqual("Warning!", actual);
	}},	
	
	// Default value with interpolation
	testDefaultValueWithInterpolation: function() { with(this) {
		actual = I18n.translate("alert", {defaultValue: "Attention! {{message}}", message: "You're out of quota!"});
		assertEqual("Attention! You're out of quota!", actual);
	}},
	
	// Default value should not be used when scope exist
	testDefaultValueShouldNotBeUsedWhenScopeExist: function() { with(this) {
		actual = I18n.translate("hello", {defaultValue: "What's up?"});
		assertEqual("Hello World!", actual);
	}},	
	
	// Default value for pluralize
	testDefaultValueForPluralize: function() { with(this) {
		options = {defaultValue: {
			none: "No things here!",
			one: "There is {{count}} thing here!",
			other: "There are {{count}} things here!"
		}};
		
		assertEqual("No things here!", I18n.pluralize(0, "things", options));
		assertEqual("There is 1 thing here!", I18n.pluralize(1, "things", options));
		assertEqual("There are 5 things here!", I18n.pluralize(5, "things", options));
	}},
	
	// Default value for pluralize should not be used when scope exist
	testDefaultValueForPluralizeShouldNotBeUsedWhenScopeExist: function() { with(this) {
		options = {defaultValue: {
			none: "No things here!",
			one: "There is {{count}} thing here!",
			other: "There are {{count}} things here!"
		}};
		
		assertEqual("You have no messages", I18n.pluralize(0, "inbox", options));
		assertEqual("You have 1 message", I18n.pluralize(1, "inbox", options));
		assertEqual("You have 5 messages", I18n.pluralize(5, "inbox", options));
	}},

	
});