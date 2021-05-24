# frozen_string_literal: true

require "test_helper"

class InitCommandTest < Minitest::Test
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  test "displays help" do
    cli = I18nJS::CLI.new(
      argv: %w[init --help],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
    assert_stdout_includes "Usage: i18n init [options]"
  end

  test "initializes project" do
    cli = I18nJS::CLI.new(
      argv: %w[init --config test/output/i18n.yml],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
    assert_file "test/output/i18n.yml"
    assert_equal "", stdout_text
  end

  test "rejects existing config file" do
    config_file = "test/output/i18n.yml"

    cli = I18nJS::CLI.new(
      argv: %W[init --config #{config_file}],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }

    cli = I18nJS::CLI.new(
      argv: %W[init --config #{config_file}],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes \
      "ERROR: #{File.expand_path(config_file)} already exists!"
  end
end
