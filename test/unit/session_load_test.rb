# frozen_string_literal: true

# Checks that restoring a session preserves saved state without contacting the model.
require 'test_helper'
require 'tarot_cli/session'

class SessionLoadTest < Minitest::Test
  class UnexpectedRunner
    def interpret(**)
      raise 'Loading must not request an interpretation.'
    end
  end

  def setup
    @reading = { 'question' => 'My question', 'cards' => ['The World', 'The Tower'],
                 'interpretation' => 'Saved interpretation' }
    capture_io do
      @session = TarotCLI::Session.from_reading(@reading, runner: UnexpectedRunner.new)
    end
  end

  def test_restores_viewable_cards_without_a_model_call
    assert_equal @reading['question'], @session.question
    assert_equal @reading['interpretation'], @session.interpretation
    output, = capture_io { @session.execute('view The World') }

    assert_includes output, Card.load_from_file(FILE_PATH).find { |card| card.name == 'The World' }.ascii_art
  end

  def test_display_reading_shows_the_question_ordered_spread_interpretation_and_commands
    ['Saved interpretation', ''].each do |interpretation|
      capture_io do
        @session = TarotCLI::Session.from_reading(@reading.merge('interpretation' => interpretation),
                                                  runner: UnexpectedRunner.new)
      end
      assert_displayed_reading(interpretation)
      assert_equal interpretation, @session.interpretation
    end
  end

  private

  def assert_displayed_reading(interpretation)
    output, = capture_io { @session.display_reading }

    assert_includes output, "Question: My question\n"
    assert_includes output, "Current Spread: [ The World ] -> [ The Tower ]\n"
    assert_includes output, "INTERPRETATION:\n#{interpretation}\n"
    assert_includes output, 'Available Commands:'
    %w[draw view save shuffle].each { |command| assert_includes output, "[#{command}" }
  end
end
