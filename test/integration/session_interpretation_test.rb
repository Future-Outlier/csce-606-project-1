# frozen_string_literal: true

require 'test_helper'
require 'tarot_cli/session'

class SessionInterpretationTest < Minitest::Test
  class FakeRunner
    attr_reader :calls

    def initialize(result: 'A connected interpretation.', error: nil)
      @result = result
      @error = error
      @calls = []
    end

    def interpret(question:, cards:)
      @calls << { question: question, cards: cards }
      raise @error if @error

      @result
    end
  end

  def setup
    cards = 4.times.map do |index|
      Card.new(id: index + 1, name: "Card #{index + 1}", description: "Description #{index + 1}")
    end
    @deck = Deck.new(cards: cards)
  end

  def test_runner_is_called_once_after_third_card_with_question_and_ordered_cards
    runner = FakeRunner.new
    session = build_session('Will this work?', runner)

    2.times { capture_io { session.execute('draw') } }
    assert_empty runner.calls

    output, = capture_io { session.execute('draw') }
    assert_successful_call(runner, output)
    assert_equal 'A connected interpretation.', session.interpretation

    assert_no_retry(session, runner)
  end

  def test_runner_failure_displays_error_without_crashing_or_retrying
    runner = FakeRunner.new(error: TarotCLI::QwenRunner::Error.new('server unavailable'))
    session = build_session('Will this work?', runner)
    2.times { capture_io { session.execute('draw') } }

    output, = capture_io { session.execute('draw') }

    assert_equal 1, runner.calls.size
    assert_includes output, 'Interpretation unavailable: server unavailable'
    assert_nil session.interpretation
    assert_no_retry(session, runner)
  end

  def test_blank_question_prevents_drawing_and_runner_call
    runner = FakeRunner.new
    session = build_session(" \t", runner)

    output, = capture_io { session.execute('draw') }

    assert_empty @deck.drawn_cards
    assert_empty runner.calls
    assert_includes output, 'enter a question before drawing'
  end

  private

  def build_session(question, runner)
    session = nil
    capture_io { session = TarotCLI::Session.new(question, deck: @deck, runner: runner) }
    session
  end

  def assert_successful_call(runner, output)
    assert_equal 1, runner.calls.size
    assert_equal 'Will this work?', runner.calls.first[:question]
    assert_equal @deck.drawn_cards, runner.calls.first[:cards]
    assert_includes output, 'FINAL INTERPRETATION:'
    assert_includes output, 'A connected interpretation.'
  end

  def assert_no_retry(session, runner)
    capture_io { session.execute('draw') }
    assert_equal 1, runner.calls.size
  end
end
