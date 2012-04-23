var I18n = require("../../lib/i18n");

describe("Defaults", function(){
  beforeEach(function(){
    I18n.reset();
  });

  it("sets the default locale", function(){
    expect(I18n.defaultLocale).toEqual("en");
  });

  it("sets current locale", function(){
    expect(I18n.locale).toEqual("en");
  });

  it("sets default separator", function(){
    expect(I18n.defaultSeparator).toEqual(".");
  });

  it("sets fallback", function(){
    expect(I18n.fallback).toEqual(false);
  });
});
