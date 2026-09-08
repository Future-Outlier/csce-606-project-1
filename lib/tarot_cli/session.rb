# frozen_string_literal: true

require_relative 'deck'

module TarotCLI
  # Owns active reading state so Shuffle clears it as one lifecycle.
  class Session
    attr_reader :question

    def initialize(question)
      @question = question
      @deck = Deck.new
      puts <<~TEXT
        [Session Initialized]
        Available Commands: [draw], [details <card>], [save], [shuffle], [help], [exit]
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
        draw_card
      when 'details'
        puts 'not yet implemented'
      when 'save'
        puts 'not yet implemented'
      when 'shuffle'
        shuffle
      end
    end

    private

    def draw_card
      if @question.to_s.strip.empty?
        puts "Start a new reading with 'new' and enter a question before drawing."
        return
      end

      puts 'Drawing card...'
      @deck.draw_card
      puts LINE
      formatted_cards = @deck.drawn_cards.map { |card| "[ #{card.name} ]" }.join(' -> ')
      puts "Current Spread: #{formatted_cards}"
      puts LINE
    end

    def shuffle
      @deck.shuffle
      @question = nil
      puts 'Session cleared and deck shuffled. Returning to Main Menu...'
      :exit
    end

    LINE = <<~TEXT
      ------------------------------------------------------------------------
    TEXT
  end
end
