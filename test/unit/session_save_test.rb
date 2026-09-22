# frozen_string_literal: true

# Verifies save guards, ordered session data, and recovery after a failed save.
require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'tarot_cli/session'

class SessionSaveTest < Minitest::Test
  class FakeRunner
    def interpret(question:, cards:)
      "Test interpretation for #{question}: #{cards.map(&:name).join(', ')}"
    end
  end

  def setup
    @directory = Dir.mktmpdir('tarot-session-save-test')
    @path = File.join(@directory, 'readings.json')
    @deck = Deck.new(cards: %w[Fool World Tower].map { |name| Card.new(id: name, name: name, description: '') })
    @session = build_session
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_saves_cards_in_draw_order_and_the_available_interpretation
    3.times { @deck.draw_card }
    result, output = execute('save')
    reading = saved_reading

    assert_equal :exit, result
    assert_includes output, 'Session successfully saved to disk. Returning to Main Menu...'
    assert_equal 'Question', reading['question']
    assert_equal @deck.drawn_cards.map(&:name), reading['cards']
    assert_equal 'An interpretation', reading['interpretation']
  end

  def test_rejects_an_empty_reading
    result, output = execute('save')

    assert_nil result
    assert_includes output, 'Cannot save an empty reading. Please draw cards first.'
    refute File.exist?(@path)
  end

  def test_failed_save_preserves_the_active_reading
    @deck.draw_card
    original_cards = @deck.drawn_cards.dup
    File.write(@path, '{broken json')
    result, output = execute('save')

    assert_nil result
    assert_includes output, 'Could not save reading:'
    assert_equal 'Question', @session.question
    assert_equal 'An interpretation', @session.interpretation
    assert_equal original_cards, @deck.drawn_cards
  end

  def test_can_draw_and_retry_after_a_failed_save
    @deck.draw_card
    File.write(@path, '{broken json')
    execute('save')
    File.write(@path, '{"readings": []}')
    execute('draw')
    result, = execute('save')

    assert_equal :exit, result
    assert_equal @deck.drawn_cards.map(&:name), saved_reading['cards']
    assert_equal 2, @deck.drawn_cards.size
  end

  private

  def saved_reading
    JSON.parse(File.read(@path))['readings'].first
  end

  def build_session(question = 'Question')
    session = nil
    capture_io do
      session = TarotCLI::Session.new(
        question, deck: @deck, runner: FakeRunner.new, interpretation: 'An interpretation', save_path: @path
      )
    end
    session
  end

  def execute(command)
    result = nil
    output, = capture_io { result = @session.execute(command) }
    [result, output]
  end
end
