# frozen_string_literal: true

require 'test_helper'
require 'tarot_cli/card'
require 'tarot_cli/deck'
require 'tarot_cli/session'

class SessionShuffleTest < Minitest::Test
  def setup
    card = Card.new(id: 1, name: 'Card', description: 'Description')
    @deck = Deck.new(cards: [card])
    @deck.draw_card
    @session = build_session
  end

  def test_shuffle_clears_all_active_state_and_returns_to_the_main_menu
    result = nil
    output, = capture_io { result = @session.execute('shuffle') }

    assert_equal :exit, result
    assert_empty @deck.drawn_cards
    assert_nil @session.question
    assert_nil @session.interpretation
    assert_includes output, 'Session cleared. All cards are available again. Returning to Main Menu...'
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
