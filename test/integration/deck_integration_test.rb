# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/tarot_cli/deck'
require_relative '../../lib/tarot_cli/card'

class TestDeck < Minitest::Test
  def test_initialize_sets_up_cards
    deck = Deck.new
    refute_empty deck.instance_variable_get(:@cards)
  end
end
