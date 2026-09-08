# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/tarot_cli/deck'
require_relative '../../lib/tarot_cli/card'

class TestDeck < Minitest::Test
  def setup
    @card_one = Card.new(id: 1, name: 'Card One', description: 'First')
    @card_two = Card.new(id: 2, name: 'Card Two', description: 'Second')
    @deck = Deck.new(cards: [@card_one, @card_two])
  end

  def test_initialize_sets_up_cards
    deck = Deck.new
    refute_empty deck.instance_variable_get(:@cards)
  end

  def test_initialize_sets_up_drawn_cards
    assert_empty @deck.drawn_cards
  end

  def test_draw_card_returns_a_card_object
    card = @deck.draw_card
    assert_instance_of Card, card
  end

  def test_draw_card_adds_drawn_card_to_history
    assert_empty @deck.drawn_cards

    first_draw = @deck.draw_card
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

  def test_draw_card_returns_nil_when_no_unique_cards_remain
    @deck.draw_card
    @deck.draw_card

    assert_nil @deck.draw_card
  end

  def test_reset_clears_drawn_cards
    @deck.draw_card

    capture_io do
      @deck.reset
    end

    assert_empty @deck.drawn_cards
  end
end
