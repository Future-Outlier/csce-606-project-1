# frozen_string_literal: true

require 'stringio'
require 'test_helper'
require 'tarot_cli/cli'

class ShuffleAcceptanceTest < Minitest::Test
  SHUFFLE_FLOW = <<~INPUT
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

  def test_shuffle_starts_a_clean_reading_with_a_new_question
    status, output = run_cli(SHUFFLE_FLOW)

    assert_equal 0, status
    assert_clean_spreads(output)
    assert_new_question_required(output)
  end

  private

  def assert_clean_spreads(output)
    spreads = output.lines.grep(/^Current Spread:/)
    assert_equal 2, spreads.length
    spreads.each { |spread| refute_includes spread, '->' }
  end

  def assert_new_question_required(output)
    assert_equal 3, output.scan('Enter your intention or question').length
  end

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
