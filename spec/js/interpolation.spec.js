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
});
