# frozen_string_literal: true

require "test_helper"

class CleanHashTest < Minitest::Test
  test "removes non accepted values" do
    expected = {b: {d: 4}}

    assert_equal expected, I18nJS.clean_hash(a: -> { }, b: {c: -> { }, d: 4})
  end
end
