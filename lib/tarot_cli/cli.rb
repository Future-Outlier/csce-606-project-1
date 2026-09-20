# frozen_string_literal: true

require_relative 'session'

module TarotCLI
  class CLI
    USAGE = <<~TEXT
      Usage: tarot [command]

      Commands:
        help, -h, --help  Show this help
        new               Start a new session
        review            Review saved past sessions
        load              Load a past saved session
        exit, quit        Exit tarot-cli
    TEXT

    COMMAND_HANDLERS = {
      'help' => :show_usage, '-h' => :show_usage, '--help' => :show_usage,
      'new' => :start_session, 'review' => :review_readings,
      'load' => :show_load_placeholder, 'draw' => :show_draw_without_reading,
      'save' => :show_save_without_reading, 'shuffle' => :show_shuffle_without_reading,
      'exit' => :exit, 'quit' => :exit
    }.freeze

    # Use one history file across readings while allowing tests to choose a temporary path.
    def initialize(runner: QwenRunner.new, save_path: ReadingStore::DEFAULT_PATH)
      @save_path = save_path
      @runner = runner
    end

    def run(arguments = [])
      unless arguments.empty?
        result = execute(arguments.join(' '))
        return result == :unknown ? 1 : 0
      end

      puts 'Welcome to tarot-cli.'
      puts "Type 'help' to see available commands."

      while (line = gets)
        break if execute(line) == :exit
      end

      0
    end

    private

    def execute(line)
      command = line.strip
      execute_command(command) unless command.empty?
    end

    # Main-menu commands must guide users who try to save without an active reading.
    def execute_command(command)
      handler = COMMAND_HANDLERS[command]
      return :exit if handler == :exit
      return send(handler) if handler

      unknown_command(command)
    end

    # Print the same command guidance used by the help flags.
    def show_usage
      puts USAGE
    end

    # Keep Load visibly planned until its session restoration contract is implemented.
    def show_load_placeholder = puts 'not yet implemented'

    # Explain why drawing must begin from a new reading.
    def show_draw_without_reading
      missing_reading('draw')
    end

    # Explain why saving requires an active reading.
    def show_save_without_reading
      missing_reading('save')
    end

    # Explain why there is no deck state to shuffle at the main menu.
    def show_shuffle_without_reading
      puts 'No active reading to shuffle.'
    end

    # Explain how to start a reading when a session-only command is used at the menu.
    def missing_reading(command)
      if command == 'save'
        puts 'Cannot save an empty reading. Please start a new reading and draw cards first.'
      else
        puts "Start a new reading with 'new' and enter a question before drawing."
      end
    end

    # Show every saved reading while keeping storage failures inside the CLI loop.
    def review_readings
      readings = ReadingStore.new(path: @save_path).readings
      return puts 'No saved readings found.' if readings.empty?

      readings.sort_by { |reading| Time.iso8601(reading['saved_at']) }.reverse_each do |reading|
        display_reading(reading)
      end
    rescue ReadingStore::Error => e
      puts "Could not review saved readings: #{e.message}"
    end

    # Render one reading record
    def display_reading(reading)
      puts <<~TEXT
        Reading ID: #{reading['ID']}
        Saved at: #{reading['saved_at']}
        Question: #{reading['question']}
        Cards: #{reading['cards'].join(' -> ')}
        Interpretation: #{reading['interpretation']}

      TEXT
    end

    # Carry the chosen runner and save destination into every new reading.
    def start_session
      question = prompt_for_question
      Session.new(question, runner: @runner, save_path: @save_path).run if question
    end

    def prompt_for_question
      loop do
        puts 'Enter your intention or question for this session: '
        question = gets&.strip
        return if question.nil?
        return question unless question.empty?

        puts 'Question cannot be blank.'
      end
    end

    def unknown_command(command)
      puts "Unknown command: #{command}"
      puts "Type 'help' to see available commands."
      :unknown
    end
  end
end
