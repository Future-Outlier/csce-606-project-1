# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/tarot_cli/deck'
require_relative '../../lib/tarot_cli/card'

class TestDeck < Minitest::Test
  def setup
    @card_one = Card.new(id: 1, name: 'Card One', description: 'First')
    @card_two = Card.new(id: 2, name: 'Card Two', description: 'Second')
    @deck = Deck.new(cards: [@card_one, @card_two])
  end

  def test_draw_card_adds_drawn_card_to_history
    assert_empty @deck.drawn_cards

    first_draw = @deck.draw_card
    assert_instance_of Card, first_draw
    assert_equal 1, @deck.drawn_cards.size
    assert_includes @deck.drawn_cards, first_draw

    second_draw = @deck.draw_card
    assert_equal 2, @deck.drawn_cards.size
    assert_includes @deck.drawn_cards, second_draw
  end

  def test_draw_card_returns_nil_when_no_cards_available
    deck = Deck.new(cards: [])
    assert_nil deck.draw_card
  end
end
