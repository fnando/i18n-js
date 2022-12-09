# frozen_string_literal: true

require "test_helper"

class PluginsCommandTest < Minitest::Test
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  test "displays help" do
    cli = I18nJS::CLI.new(
      argv: %w[plugins --help],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(0) { cli.call }
    assert_stdout_includes "Usage: i18n plugins [options]"
  end

  test "with missing require file" do
    require_file = "missing/require.rb"
    path = File.expand_path(require_file)

    cli = I18nJS::CLI.new(
      argv: %W[
        plugins
        --require #{require_file}
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }
    assert_stderr_includes %[ERROR: require file doesn't exist at "#{path}"]
  end

  test "with require file that fails to load" do
    cli = I18nJS::CLI.new(
      argv: %w[
        plugins
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

  test "returns message when no plugins have been found" do
    I18nJS.stubs(:plugin_files).returns([])

    cli = I18nJS::CLI.new(
      argv: %w[
        plugins
        --require test/config/require.rb
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }

    output = stdout.tap(&:rewind).read.chomp

    assert_includes output, "=> No plugins have been detected."
  end

  test "returns message for plugins that will be activated" do
    I18nJS.stubs(:plugin_files).returns(["/file.rb", "#{Dir.home}/another.rb"])

    cli = I18nJS::CLI.new(
      argv: %w[
        plugins
        --require test/config/require.rb
      ],
      stdout: stdout,
      stderr: stderr
    )

    assert_exit_code(1) { cli.call }

    output = stdout.tap(&:rewind).read.chomp

    assert_includes output, "   * /file"
    assert_includes output, "   * ~/another.rb"
  end
end
