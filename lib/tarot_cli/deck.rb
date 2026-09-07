# frozen_string_literal: true

class Deck
  attr_accessor :drawn_cards

  def initialize
    @drawn_cards = []
  end

  def draw_card
    cardID = rand(78)
    drawn_cards.push(cardID)
  end

  def reset
    @drawn_cards = []
    puts 'Session cleared. Returning to Main Menu...'
  end
end
