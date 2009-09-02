I18n-js
=======

It's a small library (5.2KB or 1.76KB when gzipped) to provide the Rails I18n translations on the Javascript. 

USAGE
-----

To generate your files, just run `rake i18n:setup`. This command will copy `i18n.js`
and export `messages.js` to your javascript directory.

Set your locale is easy as
	
	I18n.defaultLocale = "pt-BR";
	I18n.locale = "pt-BR";
	I18n.currentLocale();
	// pt-BR

You can use it to translate your messages:

	I18n.t("some.scoped.translation");

You can also interpolate values:

	I18n.t("hello", {name: "John Doe"});

The sample above will assume that you have the following translations in your
`config/locales/*.yml`:

	en:
	  hello: "Hello {{name}}!"

Pluralization is possible as well:

	I18n.pluralize(10, "inbox.counting");

The sample above expects the following translation:
	
	en:
	  inbox:
	    counting:
	      one: You have 1 new message
	      other: You have {{count}} new messages
	      none: You nave no messages

Rais I18n will ignore the `none` key; on Javascript, it will be used whenever the count
is zero. This is optional and you can ignore if you want.

You can localize numbers, currencies & dates:
	
	// accepted formats
	I18n.l("date.formats.short", "2009-09-18"); 		 // yyyy-mm-dd
	I18n.l("time.formats.short", "2009-09-18 23:12:43"); // yyyy-mm-dd hh:mm:ss
	I18n.l("date.formats.short", 1251862029000);		 // Epoch time
	I18n.l("date.formats.short", "09/18/2009");			 // mm/dd/yyyy
	I18n.l("date.formats.short", (new Date()));          // Date object
	
	I18n.l("currency", 1990.99);
	// $1,990.99
	
	I18n.l("number", 1990.99);
	// 1,990.99

If you prefer, you can use the `I18n.strftime` function to format dates.

	var date = new Date();
	I18n.strftime(date, "%d/%m/%Y");

The accepted formats are:

	%a - The abbreviated weekday name (Sun)
	%A - The  full  weekday  name (Sunday)
	%b - The abbreviated month name (Jan)
	%B - The  full  month  name (January)
	%c - The preferred local date and time representation
	%d - Day of the month (01..31)
	%H - Hour of the day, 24-hour clock (00..23)
	%I - Hour of the day, 12-hour clock (01..12)
	%m - Month of the year (01..12)
	%M - Minute of the hour (00..59)
	%p - Meridian indicator (AM  or  PM)
	%S - Second of the minute (00..60)
	%w - Day of the week (Sunday is 0, 0..6)
	%y - Year without a century (00..99)
	%Y - Year with century

On your development environment, you can automatically export your messages
by adding something like this to your `ApplicationController`:

	class ApplicationController < ActionController::Base
	  before_filter :export_i18n_messages
	
	  private
	    def export_i18n_messages
	      SimplesIdeias::I18n.export! if RAILS_ENV == "development"
	    end
	end

Check it out the `vendor/plugins/i18n-js/test/i18n-test.js` for more examples!

TODO
----

* Support default values for non-existing scopes
* Read `config/i18n-js.yml` file to decide which scopes should be exported to `messages.js`

MAINTAINER
----------

Nando Vieira (<http://simplesideias.com.br>)

Recommend me on [WWR](http://www.workingwithrails.com/person/7846-nando-vieira)

LICENSE:
--------

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
