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
      case command
      when 'help', '-h', '--help' then puts USAGE
      when 'new' then start_session
      when 'review', 'load' then puts 'not yet implemented'
      when 'draw', 'save' then missing_reading(command)
      when 'shuffle' then puts 'No active reading to shuffle.'
      when 'exit', 'quit' then :exit
      else
        unknown_command(command)
      end
    end

    # Explain how to start a reading when a session-only command is used at the menu.
    def missing_reading(command)
      if command == 'save'
        puts 'Cannot save an empty reading. Please start a new reading and draw cards first.'
      else
        puts "Start a new reading with 'new' and enter a question before drawing."
      end
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
