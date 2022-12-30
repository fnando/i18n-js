# frozen_string_literal: true

require "test_helper"

class SortHashTest < Minitest::Test
  test "returns non-hash objects" do
    assert_equal 1, I18nJS.sort_hash(1)
  end

  test "sorts shallow hash" do
    expected = {a: 1, b: 2, c: 3}

    assert_equal expected, I18nJS.sort_hash(c: 3, a: 1, b: 2)
  end

  test "sorts nested hash" do
    expected = {a: {b: 1, c: 2}, d: 3}

    assert_equal expected, I18nJS.sort_hash(d: 3, a: {c: 2, b: 1})
  end
end
