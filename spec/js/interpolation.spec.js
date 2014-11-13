var I18n = require("../../app/assets/javascripts/i18n")
  , Translations = require("./translations")
;

describe("Interpolation", function(){
  var actual, expected;

  beforeEach(function(){
    I18n.reset();
    I18n.translations = Translations();
  });

  it("performs single interpolation", function(){
    actual = I18n.t("greetings.name", {name: "John Doe"});
    expect(actual).toEqual("Hello John Doe!");
  });

  it("performs multiple interpolations", function(){
    actual = I18n.t("profile.details", {name: "John Doe", age: 27});
    expect(actual).toEqual("John Doe is 27-years old");
  });

  it("performs interpolation with the count option", function(){
    expect(I18n.t("inbox", {count: 0})).toEqual("You have no messages");
    expect(I18n.t("inbox", {count: 1})).toEqual("You have 1 message");
    expect(I18n.t("inbox", {count: 5})).toEqual("You have 5 messages");
  });

  it("outputs missing placeholder message if interpolation value is missing", function(){
    actual = I18n.t("greetings.name");
    expect(actual).toEqual("Hello [missing {{name}} value]!");
  });

  it("outputs missing placeholder message if interpolation value is null", function(){
    actual = I18n.t("greetings.name", {name: null});
    expect(actual).toEqual("Hello [missing {{name}} value]!");
  });

  it("allows overriding the null placeholder message", function(){
    var orig = I18n.nullPlaceholder;
    I18n.nullPlaceholder = function() {return "";}
    actual = I18n.t("greetings.name", {name: null});
    expect(actual).toEqual("Hello !");
    I18n.nullPlaceholder = orig;
  });
});
