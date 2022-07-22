# frozen_string_literal: true

require "test_helper"

class CheckCommandTest < Minitest::Test
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  test "displays help" do
    cli = I18nJS::CLI.new(
      argv: %w[check --help],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
    assert_stdout_includes "Usage: i18n check [options]"
  end

  test "without a config file" do
    cli = I18nJS::CLI.new(
      argv: %w[check],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes "ERROR: you need to specify the config file"
  end

  test "with missing file" do
    config_file = "missing/i18n.yml"
    path = File.expand_path(config_file)

    cli = I18nJS::CLI.new(
      argv: %W[check --config #{config_file}],
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
        check
        --config test/config/everything.yml
        --require #{require_file}
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes %[ERROR: require file doesn't exist at "#{path}"]
  end

  test "with existing file" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]

    cli = I18nJS::CLI.new(
      argv: %w[check --config test/config/everything.yml],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
  end

  test "with require file that fails to load" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]

    cli = I18nJS::CLI.new(
      argv: %w[
        check
        --config test/config/everything.yml
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

  test "forces colored output" do
    cli = I18nJS::CLI.new(
      argv: %w[
        check
        --config test/config/everything.yml
        --require test/config/require.rb
        --color
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }

    output = stdout.tap(&:rewind).read.chomp

    assert_includes output, "\e[31mmissing\e[0m"
    assert_includes output, "\e[33mextraneous\e[0m"
  end

  test "checks loaded translations" do
    cli = I18nJS::CLI.new(
      argv: %w[
        check
        --config test/config/everything.yml
        --require test/config/require.rb
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }

    output = stdout.tap(&:rewind).read.chomp

    assert_includes output, "=> en: 3 translations"
    assert_includes output, "=> es: 1 missing, 1 extraneous"
    assert_includes output, "- es.bye (extraneous)"
    assert_includes output, "- es.hello sunshine! (missing)"
    assert_includes output, "=> pt: 1 missing, 1 extraneous"
    assert_includes output, "- pt.bye (extraneous)"
    assert_includes output, "- pt.hello sunshine! (missing)"
  end

  test "ignores translations" do
    cli = I18nJS::CLI.new(
      argv: %w[
        check
        --config test/config/check_ignore.yml
        --require test/config/require.rb
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }

    output = stdout.tap(&:rewind).read.chomp

    assert_includes output, "=> en: 3 translations"
    assert_includes output, "=> es: 0 missing, 0 extraneous, 2 ignored"
    assert_includes output, "=> pt: 0 missing, 0 extraneous, 2 ignored"
  end
end
