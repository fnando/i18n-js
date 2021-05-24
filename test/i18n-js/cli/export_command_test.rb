# frozen_string_literal: true

require "test_helper"

class ExportCommandTest < Minitest::Test
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  test "displays help" do
    cli = I18nJS::CLI.new(
      argv: %w[export --help],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
    assert_stdout_includes "Usage: i18n export [options]"
  end

  test "without a config file" do
    cli = I18nJS::CLI.new(
      argv: %w[export],
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
      argv: %W[export --config #{config_file}],
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
        export
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
      argv: %w[export --config test/config/everything.yml],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }

    assert_file "test/output/everything.json"
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end

  test "with require file that fails to load" do
    I18n.load_path << Dir["./test/fixtures/yml/*.yml"]

    cli = I18nJS::CLI.new(
      argv: %w[
        export
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

  test "requires file" do
    cli = I18nJS::CLI.new(
      argv: %w[
        export
        --config test/config/everything.yml
        --require test/config/require.rb
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }

    assert_file "test/output/everything.json"
    assert_json_file "test/fixtures/expected/everything.json",
                     "test/output/everything.json"
  end
end
