# Checks how the CLI handles help, input, errors, and exit commands.
require "stringio"
require "test_helper"
require "tarot_cli/cli"

class CLITest < Minitest::Test
  def test_help_displays_usage
    output = run_cli("help\nexit\n")

    assert_includes output, "Usage: tarot [command]"
    assert_includes output, "help, -h, --help"
    assert_includes output, "exit, quit"
  end

  def test_help_flags_display_usage
    ["-h", "--help"].each do |flag|
      output = StringIO.new

      status = TarotCLI::CLI.new(output: output).run([flag])

      assert_equal 0, status
      assert_includes output.string, "Usage: tarot [command]"
    end
  end

  def test_unknown_command_displays_error_and_help_hint
    output = run_cli("fortune\nexit\n")

    assert_includes output, "Unknown command: fortune"
    assert_includes output, "Type 'help' to see available commands."
  end

  def test_unknown_command_argument_exits_with_error
    output = StringIO.new

    status = TarotCLI::CLI.new(output: output).run(["fortune"])

    assert_equal 1, status
    assert_includes output.string, "Unknown command: fortune"
  end

  def test_blank_input_is_ignored
    output = run_cli("\nexit\n")

    refute_includes output, "Unknown command"
  end

  def test_exit_commands_stop_reading_commands
    ["exit", "quit"].each do |command|
      output = run_cli("#{command}\nhelp\n")

      refute_includes output, "Usage: tarot [command]"
    end
  end

  def test_end_of_input_exits_successfully
    output = StringIO.new
    status = TarotCLI::CLI.new(input: StringIO.new, output: output).run

    assert_equal 0, status
  end

  private

  def run_cli(input)
    output = StringIO.new
    TarotCLI::CLI.new(input: StringIO.new(input), output: output).run
    output.string
  end
end
