var I18n = require("../../app/assets/javascripts/i18n")
  , Translations = require("./translations")
;

describe("Pluralization", function(){
  var actual, expected;

  beforeEach(function(){
    I18n.reset();
    I18n.translations = Translations();
  });

  it("sets alias", function() {
    expect(I18n.p).toEqual(I18n.pluralize);
  });

  it("pluralizes scope", function(){
    expect(I18n.p(0, "inbox")).toEqual("You have no messages");
    expect(I18n.p(1, "inbox")).toEqual("You have 1 message");
    expect(I18n.p(5, "inbox")).toEqual("You have 5 messages");
  });

  it("pluralizes using the 'other' scope", function(){
    I18n.translations["en"]["inbox"]["zero"] = null;
    expect(I18n.p(0, "inbox")).toEqual("You have 0 messages");
  });

  it("pluralizes using the 'zero' scope", function(){
    I18n.translations["en"]["inbox"]["zero"] = "No messages (zero)";

    expect(I18n.p(0, "inbox")).toEqual("No messages (zero)");
  });

  it("pluralizes using negative values", function(){
    expect(I18n.p(-1, "inbox")).toEqual("You have -1 message");
    expect(I18n.p(-5, "inbox")).toEqual("You have -5 messages");
  });

  it("returns missing translation", function(){
    expect(I18n.p(-1, "missing")).toEqual('[missing "en.missing" translation]');
  });

  it("pluralizes using multiple placeholders", function(){
    actual = I18n.p(1, "unread", {unread: 5});
    expect(actual).toEqual("You have 1 new message (5 unread)");

    actual = I18n.p(10, "unread", {unread: 2});
    expect(actual).toEqual("You have 10 new messages (2 unread)");

    actual = I18n.p(0, "unread", {unread: 5});
    expect(actual).toEqual("You have no new messages (5 unread)");
  });

  it("allows empty strings", function(){
    I18n.translations["en"]["inbox"]["zero"] = "";

    expect(I18n.p(0, "inbox")).toEqual("");
  });

  it("pluralizes using custom rules", function() {
    I18n.locale = "custom";

    I18n.pluralization["custom"] = function(count) {
      if (count === 0) { return ["zero"]; }
      if (count >= 1 && count <= 5) { return ["few", "other"]; }
      return ["other"];
    };

    I18n.translations["custom"] = {
      "things": {
          "zero": "No things"
        , "few": "A few things"
        , "other": "%{count} things"
      }
    }

    expect(I18n.p(0, "things")).toEqual("No things");
    expect(I18n.p(4, "things")).toEqual("A few things");
    expect(I18n.p(10, "things")).toEqual("10 things");
  });

  it("pluralizes default value", function(){
    options = {defaultValue: {
        zero: "No things here!"
      , one: "There is {{count}} thing here!"
      , other: "There are {{count}} things here!"
    }};

    expect(I18n.p(0, "things", options)).toEqual("No things here!");
    expect(I18n.p(1, "things", options)).toEqual("There is 1 thing here!");
    expect(I18n.p(5, "things", options)).toEqual("There are 5 things here!");
  });

  it("ignores pluralization when scope exists", function(){
    options = {defaultValue: {
        zero: "No things here!"
      , one: "There is {{count}} thing here!"
      , other: "There are {{count}} things here!"
    }};

    expect(I18n.p(0, "inbox", options)).toEqual("You have no messages");
    expect(I18n.p(1, "inbox", options)).toEqual("You have 1 message");
    expect(I18n.p(5, "inbox", options)).toEqual("You have 5 messages");
  });
});
