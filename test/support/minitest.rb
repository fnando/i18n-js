# frozen_string_literal: true

require "fileutils"

module Minitest
  class Test
    setup do
      reset_i18n
      FileUtils.rm_rf "./test/output"
    end

    teardown do
      FileUtils.rm_rf "./test/output"
    end

    private def assert_schema_error(message)
      error = nil

      begin
        yield
      rescue I18nJS::Schema::InvalidError => error
        # do nothing
      end

      assert error, "Expected block to have raised a schema error"
      assert_includes error.message, message
    end

    private def assert_file(path)
      path = File.expand_path(path)
      assert File.file?(path), "Expected #{path} to be a file"
    end

    private def assert_json_file(expected_file, actual_file)
      expected = ::JSON.parse(File.read(File.expand_path(expected_file)))
      actual = ::JSON.parse(File.read(File.expand_path(actual_file)))

      assert_equal expected, actual
    end

    private def assert_exit_code(expected_code)
      yield
    rescue SystemExit => error
      assert_equal expected_code, error.exception.status
    end

    private def assert_stdout_includes(text)
      assert_includes stdout_text, text
    end

    private def assert_stderr_includes(text)
      assert_includes stderr_text, text
    end

    private def stdout_text
      stdout.tap(&:rewind).read
    end

    private def stderr_text
      stderr.tap(&:rewind).read
    end
  end
end
