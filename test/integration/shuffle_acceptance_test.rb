# frozen_string_literal: true

require 'stringio'
require 'test_helper'
require 'tarot_cli/cli'

class ShuffleAcceptanceTest < Minitest::Test
  class FakeRunner
    attr_reader :questions

    def initialize
      @questions = []
    end

    def interpret(question:, cards:)
      @questions << question
      "#{question}: #{cards.map(&:name).join(', ')}"
    end
  end

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
    runner = FakeRunner.new
    status, output = run_cli(SHUFFLE_FLOW, runner)

    assert_equal 0, status
    assert_clean_spreads(output)
    assert_equal ['First question', 'Second question'], runner.questions
    assert_includes output, 'First question: '
    assert_includes output, 'Second question: '
    assert_includes output, 'Question cannot be blank.'
  end

  private

  def assert_clean_spreads(output)
    spreads = output.lines.grep(/^Current Spread:/)
    assert_equal 2, spreads.length
    spreads.each { |spread| refute_includes spread, '->' }
  end

  def run_cli(input, runner)
    original_stdin = $stdin
    $stdin = StringIO.new(input)
    status = nil
    output, = capture_io { status = TarotCLI::CLI.new(runner: runner).run }
    [status, output]
  ensure
    $stdin = original_stdin
  end
end
