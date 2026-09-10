# frozen_string_literal: true

require 'test_helper'
require 'tarot_cli/session'

class DeckSpy
  attr_reader :shuffle_calls

  def initialize
    @shuffle_calls = 0
  end

  def shuffle
    @shuffle_calls += 1
  end
end

class SessionShuffleTest < Minitest::Test
  def setup
    @deck = DeckSpy.new
    @session = build_session
  end

  def test_shuffle_clears_all_active_state_and_returns_to_the_main_menu
    result = nil
    capture_io { result = @session.execute('shuffle') }

    assert_equal :exit, result
    assert_equal 1, @deck.shuffle_calls
    assert_nil @session.question
    assert_nil @session.interpretation
  end

  private

  def build_session
    session = nil
    capture_io do
      session = TarotCLI::Session.new(
        'Old question',
        deck: @deck,
        interpretation: 'Old interpretation'
      )
    end
    session
  end
end
