# frozen_string_literal: true

require_relative 'deck'

module TarotCLI
  class Session
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
      case command
      when ''
        nil
      when 'draw'
        puts 'Drawing card...'
        @deck.draw_card
        puts LINE
        formatted_cards = @deck.drawn_cards.map { |card| "[ #{card.name} ]" }.join(' -> ')
        puts "Current Spread: #{formatted_cards}"
        puts LINE
      when 'details'
        puts 'not yet implemented'
      when 'save'
        puts 'not yet implemented'
      when 'reset'
        puts 'not yet implemented'
      end
    end

    LINE = <<~TEXT
      ------------------------------------------------------------------------
    TEXT
  end
end
