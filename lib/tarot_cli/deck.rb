# frozen_string_literal: true

require_relative 'card'

FILE_PATH = File.expand_path('../data/cards.json', __dir__)

class Deck
  attr_reader :drawn_cards

  def initialize(cards: nil)
    @cards = cards || Card.load_from_file(FILE_PATH)
    @drawn_cards = []
  end

  def draw_card
    available_cards = @cards - @drawn_cards
    return nil if available_cards.empty?

    card = available_cards.sample
    @drawn_cards.push(card)
    card
  end

  def shuffle
    @drawn_cards.clear
  end

  # Reuse the deck's cards so restored cards keep their art and cannot be drawn again.
  def restore(card_names)
    cards = card_names.map { |name| @cards.find { |card| card.name == name } }
    if cards.include?(nil) || cards.uniq != cards
      raise ArgumentError, 'Saved reading contains unknown or duplicate cards.'
    end

    @drawn_cards = cards
  end

  def find_drawn_card(selection)
    value = selection.to_s.strip
    @drawn_cards.find { |card| card.name.casecmp?(value) }
  end
end
