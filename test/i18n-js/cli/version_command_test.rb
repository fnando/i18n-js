# frozen_string_literal: true

require "test_helper"

class VersionCommandTest < Minitest::Test
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  test "displays version" do
    cli = I18nJS::CLI.new(
      argv: %w[version],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
    assert_stdout_includes "v#{I18nJS::VERSION}"
  end
end
