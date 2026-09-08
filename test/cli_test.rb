require 'stringio'
require 'test_helper'
require 'tarot_cli/cli'

class CLITest < Minitest::Test
  def test_help_displays_usage
    _status, output = run_cli("help\nexit\n")

    assert_includes output, 'Usage: tarot [command]'
    assert_includes output, 'help, -h, --help'
    assert_includes output, 'exit, quit'
  end

  def test_help_flags_display_usage
    ['-h', '--help'].each do |flag|
      status, output = run_cli('', [flag])

      assert_equal 0, status
      assert_includes output, 'Usage: tarot [command]'
    end
  end

  def test_interactive_mode_reports_unknown_command_and_continues
    _status, output = run_cli("unknown\nexit\n")

    assert_includes output, 'Unknown command: unknown'
    assert_includes output, "Type 'help' to see available commands."
  end

  def test_single_command_mode_returns_error_for_unknown_command
    status, output = run_cli('', ['unknown'])

    assert_equal 1, status
    assert_includes output, 'Unknown command: unknown'
  end

  def test_blank_input_is_ignored
    _status, output = run_cli("\nexit\n")

    refute_includes output, 'Unknown command'
  end

  def test_exit_commands_stop_reading_commands
    %w[exit quit].each do |command|
      _status, output = run_cli("#{command}\nhelp\n")

      refute_includes output, 'Usage: tarot [command]'
    end
  end

  def test_end_of_input_exits_successfully
    status, = run_cli('')

    assert_equal 0, status
  end

  private

  def run_cli(input, arguments = [])
    original_stdin = $stdin
    $stdin = StringIO.new(input)
    status = nil
    output, = capture_io { status = TarotCLI::CLI.new.run(arguments) }
    [status, output]
  ensure
    $stdin = original_stdin
  end
end
