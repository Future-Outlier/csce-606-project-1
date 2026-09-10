# frozen_string_literal: true

require 'test_helper'
require 'tarot_cli/card'
require 'tarot_cli/deck'

class DeckShuffleTest < Minitest::Test
  def setup
    @cards = (1..4).map do |id|
      Card.new(id: id, name: "Card #{id}", description: "Description #{id}")
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
    assert_equal card_ids(first_reading), card_ids(second_reading)
    assert_equal second_reading.length, second_reading.uniq.length
  end

  private

  def draw_all_cards
    @cards.length.times.map { @deck.draw_card }
  end

  def card_ids(cards)
    cards.map(&:id).sort
  end
end
