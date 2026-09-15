# frozen_string_literal: true

require_relative 'deck'
require_relative 'qwen_runner'
require_relative 'reading_store'

module TarotCLI
  class Session
    MAX_CARDS = 3
    LINE = <<~TEXT
      ------------------------------------------------------------------------
    TEXT

    attr_reader :question, :interpretation

    # Keep the active reading and its save destination together for this session.
    def initialize(question, deck: Deck.new, runner: QwenRunner.new, interpretation: nil, save_path: ReadingStore::DEFAULT_PATH)
      @question = question
      @deck = deck
      @runner = runner
      @interpretation = interpretation
      @reading_store = ReadingStore.new(path: save_path)
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

    # Session commands operate on the active reading until it returns to the main menu.
    def execute(line)
      command = line.strip
      return if command.empty?

      case command
      when 'draw' then draw_card
      when 'details' then puts 'not yet implemented'
      when 'save' then save
      when 'shuffle' then shuffle
      end
    end

    private

    # Return to the menu only after saving succeeds, keeping a failed reading available to retry.
    def save
      error = save_error
      return puts(error) if error

      @reading_store.save(question: @question, cards: @deck.drawn_cards.map(&:name), interpretation: @interpretation)
      puts 'Session successfully saved to disk. Returning to Main Menu...'
      :exit
    rescue ReadingStore::Error => e
      puts "Could not save reading: #{e.message}"
    end

    # A useful saved reading needs both a question and at least one drawn card.
    def save_error
      return 'Cannot save a reading without a question. Start a new reading first.' if @question.to_s.strip.empty?

      'Cannot save an empty reading. Please draw cards first.' if @deck.drawn_cards.empty?
    end

    def draw_card
      return missing_question if @question.to_s.strip.empty?

      if @deck.drawn_cards.size >= MAX_CARDS
        puts "Maximum of #{MAX_CARDS} cards reached. Shuffle before drawing again."
        return
      end

      puts 'Drawing card...'
      return unless @deck.draw_card

      display_spread
      interpret_spread
    end

    def display_spread
      puts LINE
      puts "Current Spread: #{formatted_cards}"
      puts LINE
    end

    def missing_question
      puts "Start a new reading with 'new' and enter a question before drawing."
    end

    def interpret_spread
      @interpretation = nil
      @interpretation = @runner.interpret(
        question: @question,
        cards: @deck.drawn_cards.dup
      )
      puts 'INTERPRETATION:'
      puts @interpretation
    rescue StandardError => e
      puts "Interpretation unavailable: #{e.message}"
    end

    def shuffle
      @deck.shuffle
      @question = nil
      @interpretation = nil
      puts 'Session cleared. All cards are available again. Returning to Main Menu...'
      :exit
    end

    def formatted_cards
      @deck.drawn_cards.map { |card| "[ #{card.name} ]" }.join(' -> ')
    end
  end
end
