# frozen_string_literal: true

require "test_helper"

class LintCommandTest < Minitest::Test
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  test "displays help" do
    cli = I18nJS::CLI.new(
      argv: %w[lint:scripts --help],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
    assert_stdout_includes "Usage: i18n lint:scripts [options]"
  end

  test "without a config file" do
    cli = I18nJS::CLI.new(
      argv: %w[lint:scripts],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes "ERROR: you need to specify the config file"
  end

  test "with missing config file" do
    config_file = "missing/i18n.yml"
    path = File.expand_path(config_file)

    cli = I18nJS::CLI.new(
      argv: %W[lint:scripts --config #{config_file}],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes %[ERROR: config file doesn't exist at "#{path}"]
  end

  test "with missing require file" do
    require_file = "missing/require.rb"
    path = File.expand_path(require_file)

    cli = I18nJS::CLI.new(
      argv: %W[
        lint:scripts
        --config test/config/lint_scripts.yml
        --require #{require_file}
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes %[ERROR: require file doesn't exist at "#{path}"]
  end

  test "with missing node bin" do
    cli = I18nJS::CLI.new(
      argv: %w[
        lint:scripts
        --config test/config/lint_scripts.yml
        --require test/config/require.rb
        --node-path /invalid/path/to/node
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes "=> ERROR: node.js couldn't be found " \
                           "(path: /invalid/path/to/node)"
  end

  test "with require file that fails to load" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]

    cli = I18nJS::CLI.new(
      argv: %w[
        lint:scripts
        --config test/config/lint_scripts.yml
        --require test/config/require_error.rb
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }

    assert_stderr_includes "RuntimeError => 💣"
    assert_stderr_includes \
      %[ERROR: couldn't load "test/config/require_error.rb"]
  end

  test "lints files" do
    cli = I18nJS::CLI.new(
      argv: %w[
        lint:scripts
        --config test/config/lint_scripts.yml
        --require test/config/require.rb
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(8) { cli.call }

    output = format(
      File.read("./test/fixtures/expected/lint.txt"),
      node: `which node`.chomp
    )

    assert_stdout_includes(output)
  end
end
