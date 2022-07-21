# frozen_string_literal: true

require "test_helper"

class UITest < Minitest::Test
  class FakeIO < StringIO
    attr_writer :tty

    def tty?
      @tty
    end
  end

  let(:io) { StringIO.new }

  teardown do
    ENV.delete("NO_COLOR")
  end

  test "returns ansi text when detecting tty" do
    io = FakeIO.new
    io.tty = true

    ui = I18nJS::CLI::UI.new(stdout: io, stderr: io)
    assert_equal "\e[33mhello\e[0m", ui.yellow("hello")
  end

  test "returns plain text when not detecting tty" do
    io = FakeIO.new
    io.tty = false

    ui = I18nJS::CLI::UI.new(stdout: io, stderr: io)
    assert_equal "hello", ui.yellow("hello")
  end

  test "returns plain text when detect tty but NO_COLOR is set" do
    ENV["NO_COLOR"] = "1"
    io = FakeIO.new
    io.tty = true

    ui = I18nJS::CLI::UI.new(stdout: io, stderr: io)
    assert_equal "hello", ui.yellow("hello")
  end

  test "returns ansi text when colored is set" do
    ui = I18nJS::CLI::UI.new(stdout: io, stderr: io, colored: true)
    assert_equal "\e[33mhello\e[0m", ui.yellow("hello")
  end

  test "returns plain text when colored is not set" do
    ui = I18nJS::CLI::UI.new(stdout: io, stderr: io, colored: false)
    assert_equal "hello", ui.yellow("hello")
  end

  test "returns plain text when colored is set but so is NO_COLOR" do
    ENV["NO_COLOR"] = "1"
    ui = I18nJS::CLI::UI.new(stdout: io, stderr: io, colored: true)
    assert_equal "hello", ui.yellow("hello")
  end
end
