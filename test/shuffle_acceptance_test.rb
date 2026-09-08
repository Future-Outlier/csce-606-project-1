# frozen_string_literal: true

require 'stringio'
require 'test_helper'
require 'tarot_cli/cli'

class ShuffleAcceptanceTest < Minitest::Test
  def test_shuffle_starts_a_clean_reading_with_a_new_question
    input = <<~INPUT
      new
      First question
      draw
      shuffle
      draw
      new

      Second question
      draw
      shuffle
      exit
    INPUT

    status, output = run_cli(input)
    spreads = output.lines.grep(/^Current Spread:/)

    assert_equal 0, status
    assert_equal 2, spreads.length
    spreads.each { |spread| refute_includes spread, '->' }
    assert_equal 2, output.scan('Session cleared. All cards are available again. Returning to Main Menu...').length
    assert_equal 3, output.scan('Enter your intention or question for this session:').length
    assert_includes output, "Start a new reading with 'new' and enter a question before drawing."
    assert_includes output, 'Question cannot be blank.'
  end

  private

  def run_cli(input)
    original_stdin = $stdin
    $stdin = StringIO.new(input)
    status = nil
    output, = capture_io { status = TarotCLI::CLI.new.run }
    [status, output]
  ensure
    $stdin = original_stdin
  end
end
