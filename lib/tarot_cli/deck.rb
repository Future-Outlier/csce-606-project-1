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

  def reset
    @drawn_cards = []
    puts 'Session cleared. Returning to Main Menu...'
  end
end
