# frozen_string_literal: true

require "test_helper"

class RootCommandTest < Minitest::Test
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  test "shows help on root" do
    cli = I18nJS::CLI.new(argv: [], stdout: stdout, stderr: stderr)

    assert_exit_code(1) { cli.call }
    assert_includes stderr.tap(&:rewind).read, "Usage: i18n COMMAND FLAGS"
  end
end
