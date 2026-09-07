# frozen_string_literal: true

require_relative 'card'

FILE_PATH = File.expand_path('../data/cards.json', __dir__)

class Deck
  attr_reader :drawn_cards

  def initialize
    @cards = Card.load_from_file(FILE_PATH)
    @drawn_cards = []
  end

  def draw_card
    id = rand(@cards.size)
    card = @cards[id]
    drawn_cards.push(card)
  end

  def reset
    @drawn_cards = []
    puts 'Session cleared. Returning to Main Menu...'
  end
end
