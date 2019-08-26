var I18n = require("../../app/assets/javascripts/i18n");

describe("Duration", function(){
  var actual, expected;

  beforeEach(function() {
    I18n.reset();
  });

  it("doesn't add clients timezone", function() {
    // 1 hour 5 minutes = 3900 seconds
    var duration = new Date(3900 * 1000);

    // 24-hour
    expect(I18n.strftime(duration, "%-H", true)).toEqual("1");
    expect(I18n.strftime(duration, "%H", true)).toEqual("01");

    // 12-hour
    expect(I18n.strftime(duration, "%-I", true)).toEqual("1");
    expect(I18n.strftime(duration, "%I", true)).toEqual("01");

    // minutes
    expect(I18n.strftime(duration, "%-M", true)).toEqual("5");
    expect(I18n.strftime(duration, "%M", true)).toEqual("05");
  });
});
