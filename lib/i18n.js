// Instantiate the object
var I18n = I18n || {};

// Set default locale to english
I18n.defaultLocale = "en";

// Set current locale to null
I18n.locale = null;

I18n.lookup = function(scope, options) {
	var translations = I18n.translations || {};
	var messages = translations[I18n.currentLocale()];
	options = options || {};
	
	if (!messages) {
		return;
	}
	
	scope = scope.split(".");
	
	while (scope.length > 0) {
		var currentScope = scope.shift();		
		messages = messages[currentScope];
		
		if (!messages) {
			break;
		}
	}
	
	if (!messages && options.defaultValue != null && options.defaultValue != undefined) {
		messages = options.defaultValue;
	}
	
	return messages;
};

I18n.interpolate = function(message, options) {
	options = options || {};
	var regex = /\{\{(.*?)\}\}/gm;
	var matches = message.match(regex);

	if (!matches) {
		return message;
	}
	
	var placeholder, value, name;
	
	for (var i = 0; placeholder = matches[i]; i++) {
		name = placeholder.replace(/\{\{(.*?)\}\}/gm, "$1");
		
		value = options[name];
		
		if (options[name] == null || options[name] == undefined) {
			value = "[missing " + placeholder + " value]";
		}
		
		regex = new RegExp(placeholder.replace(/\{/gm, "\\{").replace(/\}/gm, "\\}"));
		
		message = message.replace(regex, value);
	}
	
	return message;
};

I18n.translate = function(scope, options) {
	try {
		var message = this.lookup(scope, options);
		return this.interpolate(message, options);
	} catch(err) {
		if (window.console) {
			console.debug("translation missing: " + I18n.currentLocale() + "." + scope);
		}
		return scope;
	}
};

I18n.localize = function(scope, value) {
	switch (scope) {
		case "currency":
			return this.toCurrency(value);
		case "number":
			scope = this.lookup("number.format");
			return this.toNumber(value, scope);
		default:
			if (scope.match(/^(date|time)/)) {
				return this.toTime(scope, value);
			} else {
				return value.toString();
			}
	}
};

I18n.parseDate = function(d) {
	var matches, date;
	var year, month, day, hour, min, sec = null;
	
	if (matches = d.toString().match(/(\d{4})-(\d{2})-(\d{2})(?:[ |T](\d{2}):(\d{2}):(\d{2}))?(Z)?/)) {
		// date/time strings: yyyy-mm-dd hh:mm:ss or yyyy-mm-dd or yyyy-mm-ddThh:mm:ssZ
		for (var i = 1; i <= 6; i++) {
			matches[i] = matches[i] == undefined? 0 : parseInt(matches[i], 10);
		}
		
		// month starts on 0
		matches[2] = matches[2] - 1;
		
		if (matches[7]) {
		  date = new Date(Date.UTC(matches[1], matches[2], matches[3], matches[4], matches[5], matches[6]));
		} else {
		  date = new Date(matches[1], matches[2], matches[3], matches[4], matches[5], matches[6]);
		}
	} else if (typeof(d) == "number") {
		// UNIX timestamp
		date = new Date();
		date.setTime(d);
	} else {
		// an arbitrary javascript string
		date = new Date();
		date.setTime(Date.parse(d));        
	}
	
	return date;
};

I18n.toTime = function(scope, d) {
	var date = this.parseDate(d);
	var format = this.lookup(scope);
	
	if (date.toString().match(/invalid/i)) {
		return date.toString();
	}
	
	if (!format) {
		return date.toString();
	}
	
	return this.strftime(date, format);
};

I18n.strftime = function(date, format) {
	var options = this.lookup("date");
	
	if (!options) {
		return date.toString();
	}
	
	var weekDay = date.getDay();
	var day = date.getDate();
	var year = date.getFullYear();
	var month = date.getMonth() + 1;
	var hour = date.getHours();
	var hour12 = hour;
	var meridian = hour > 12? "PM" : "AM";
	var secs = date.getSeconds();
	var mins = date.getMinutes();
	var offset = date.getTimezoneOffset();
	var absOffsetHours = Math.floor(Math.abs(offset / 60));
	var absOffsetMinutes = Math.abs(offset) - (absOffsetHours * 60);
	var timezoneoffset = (offset > 0 ? "-" : "+") + (absOffsetHours.toString().length < 2 ? '0' + absOffsetHours : absOffsetHours) + (absOffsetMinutes.toString().length < 2 ? '0' + absOffsetMinutes : absOffsetMinutes);  
	
	if (hour12 > 12) {
		hour12 = hour12 - 12;
	};
	
	var helper = function(n) {
		var s = "0" + n.toString();
		return s.substr(s.length - 2);
	};
	
	var f = format;
	f = f.replace("%a", options["abbr_day_names"][weekDay]);
	f = f.replace("%A", options["day_names"][weekDay]);
	f = f.replace("%b", options["abbr_month_names"][month]);
	f = f.replace("%B", options["month_names"][month]);
	f = f.replace("%d", helper(day));
	f = f.replace("%H", helper(hour));
	f = f.replace("%I", hour12);
	f = f.replace("%m", helper(month));
	f = f.replace("%M", helper(mins));
	f = f.replace("%p", meridian);
	f = f.replace("%S", helper(secs));
	f = f.replace("%w", weekDay);
	f = f.replace("%y", helper(year));
	f = f.replace("%Y", year);
	f = f.replace("%z", timezoneoffset);
	
	return f;
};

I18n.toNumber = function(number, options) {
	options = options || {
		precision: 2,
		separator: ',',
		delimiter: '.'
	}
	
	var string = number.toFixed(options["precision"]).toString();
	var parts = string.split(".");
	
	number = parts[0];
	var precision = parts[1];
	
	var n = [];
	
	while (number.length > 0) {
		n.unshift(number.substr(Math.max(0, number.length - 3), 3));
		number = number.substr(0, number.length -3);
	}
	
	return n.join(options["separator"]) + options["delimiter"] + parts[1];
};

I18n.toCurrency = function(number) {
	var options = this.lookup("number.currency.format");
	
	if (!options) {
		options = {
			unit: "$",
			precision: 2,
			format: "%u%n",
			separator: ",",
			delimiter: "."
		};
	}
	
	// first, convert number
	number = this.toNumber(number, options);
	number = options["format"]
				.replace("%u", options["unit"])
				.replace("%n", number);
	
	return number;
};

I18n.pluralize = function(count, scope, options) {
	scope = this.lookup(scope, options);
	
	var message;
	options = options || {};
	options["count"] = count.toString();

	switch(Math.abs(count)) {
		case 0:
			message = scope["none"] || scope["other"] || "missing '" + scope + ".none' scope";
			break;
		case 1:
			message = scope["one"] || "missing '" + scope + ".one' scope";
			break;
		default:
			message = scope["other"] || "missing '" + scope + ".other' scope";
	}
	
	return this.interpolate(message, options);
};

I18n.currentLocale = function() {
	return (I18n.locale || I18n.defaultLocale);
};

// shortcuts
I18n.t = I18n.translate;
I18n.l = I18n.localize;