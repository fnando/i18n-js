var I18n = require("../../app/assets/javascripts/i18n")
  , Translations = require("./translations")
;

describe("Translate", function(){
  var actual, expected;

  beforeEach(function(){
    I18n.reset();
    I18n.translations = Translations();
  });

  it("returns translation for single scope", function(){
    expect(I18n.t("hello")).toEqual("Hello World!");
  });

  it("returns translation as object", function(){
    expect(I18n.t("greetings")).toEqual(I18n.translations.en.greetings);
  });

  it("returns missing message translation for invalid scope", function(){
    actual = I18n.t("invalid.scope");
    expected = '[missing "en.invalid.scope" translation]';
    expect(actual).toEqual(expected);
  });

  it("returns translation for single scope on a custom locale", function(){
    I18n.locale = "pt-BR";
    expect(I18n.t("hello")).toEqual("Olá Mundo!");
  });

  it("returns translation for multiple scopes", function(){
    expect(I18n.t("greetings.stranger")).toEqual("Hello stranger!");
  });

  it("returns translation with default locale option", function(){
    expect(I18n.t("hello", {locale: "en"})).toEqual("Hello World!");
    expect(I18n.t("hello", {locale: "pt-BR"})).toEqual("Olá Mundo!");
  });

  it("fallbacks to the default locale when I18n.fallbackss is enabled", function(){
    I18n.locale = "pt-BR";
    I18n.fallbacks = true;
    expect(I18n.t("greetings.stranger")).toEqual("Hello stranger!");
  });

  it("fallbacks to default locale when providing an unknown locale", function(){
    I18n.locale = "fr";
    I18n.fallbacks = true;
    expect(I18n.t("greetings.stranger")).toEqual("Hello stranger!");
  });

  it("fallbacks to less specific locale", function(){
    I18n.locale = "de-DE";
    I18n.fallbacks = true;
    expect(I18n.t("hello")).toEqual("Hallo Welt!");
  });

  it("fallbacks using custom rules (function)", function(){
    I18n.locale = "no";
    I18n.fallbacks = true;
    I18n.locales["no"] = function() {
      return ["nb"];
    };

    expect(I18n.t("hello")).toEqual("Hei Verden!");
  });

  it("fallbacks using custom rules (array)", function() {
    I18n.locale = "no";
    I18n.fallbacks = true;
    I18n.locales["no"] = ["no", "nb"];

    expect(I18n.t("hello")).toEqual("Hei Verden!");
  });

  it("fallbacks using custom rules (string)", function() {
    I18n.locale = "no";
    I18n.fallbacks = true;
    I18n.locales["no"] = "nb";

    expect(I18n.t("hello")).toEqual("Hei Verden!");
  });

  it("uses default value for simple translation", function(){
    actual = I18n.t("warning", {defaultValue: "Warning!"});
    expect(actual).toEqual("Warning!");
  });

  it("uses default value for unknown locale", function(){
    I18n.locale = "fr";
    actual = I18n.t("warning", {defaultValue: "Warning!"});
    expect(actual).toEqual("Warning!");
  });

  it("uses default value with interpolation", function(){
    actual = I18n.t(
      "alert",
      {defaultValue: "Attention! {{message}}", message: "You're out of quota!"}
    );

    expect(actual).toEqual("Attention! You're out of quota!");
  });

  it("ignores default value when scope exists", function(){
    actual = I18n.t("hello", {defaultValue: "What's up?"});
    expect(actual).toEqual("Hello World!");
  });

  it("returns translation for custom scope separator", function(){
    I18n.defaultSeparator = "•";
    actual = I18n.t("greetings•stranger");
    expect(actual).toEqual("Hello stranger!");
  });

  it("returns boolean values", function() {
    expect(I18n.t("booleans.yes")).toEqual(true);
    expect(I18n.t("booleans.no")).toEqual(false);
  });
});
