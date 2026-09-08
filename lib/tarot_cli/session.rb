# frozen_string_literal: true

require_relative 'deck'

module TarotCLI
  class Session
    LINE = <<~TEXT
      ------------------------------------------------------------------------
    TEXT

    def initialize(question)
      @question = question
      @deck = Deck.new
      puts <<~TEXT
        [Session Initialized]
        Available Commands: [draw], [details <card>], [save], [reset], [help], [exit]
      TEXT
    end

    def run
      while (line = gets)
        break if execute(line) == :exit
      end

      0
    end

    def execute(line)
      command = line.strip
      return if command.empty?

      case command
      when 'draw' then draw_card
      when 'details', 'save', 'reset' then puts 'not yet implemented'
      end
    end

    private

    def draw_card
      puts 'Drawing card...'
      @deck.draw_card
      puts LINE
      puts "Current Spread: #{formatted_cards}"
      puts LINE
    end

    def formatted_cards
      @deck.drawn_cards.map { |card| "[ #{card.name} ]" }.join(' -> ')
    end
  end
end
