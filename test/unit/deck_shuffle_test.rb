# frozen_string_literal: true

require 'test_helper'
require 'tarot_cli/card'
require 'tarot_cli/deck'

class DeckShuffleTest < Minitest::Test
  def setup
    @cards = (1..4).map do |number|
      Card.new(name: "Card #{number}", description: "Description #{number}")
    end
    @deck = Deck.new(cards: @cards)
  end

  def test_shuffle_clears_drawn_cards
    original_order = @cards.dup
    2.times { @deck.draw_card }

    @deck.shuffle

    assert_empty @deck.drawn_cards
    assert_equal original_order, @cards
  end

  def test_shuffle_returns_every_drawn_card_to_the_pool
    first_reading = draw_all_cards
    assert_nil @deck.draw_card

    @deck.shuffle

    second_reading = draw_all_cards
    assert_equal card_names(first_reading), card_names(second_reading)
  end

  private

  def draw_all_cards
    @cards.length.times.map { @deck.draw_card }
  end

  def card_names(cards)
    cards.map(&:name).sort
  end
end
