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

      case command
      when ''
        nil
      when 'help', '-h', '--help'
        puts USAGE
      when 'new'
        start_session
      when 'review'
        puts 'not yet implemented'
      when 'load'
        puts 'not yet implemented'
      when 'draw'
        puts "Start a new reading with 'new' and enter a question before drawing."
      when 'shuffle'
        puts 'No active reading to shuffle.'
      when 'exit', 'quit'
        :exit
      else
        puts "Unknown command: #{command}"
        puts "Type 'help' to see available commands."
        :unknown
      end
    end

    def start_session
      loop do
        puts 'Enter your intention or question for this session: '
        question = gets
        return if question.nil?

        question = question.strip
        if question.empty?
          puts 'Question cannot be blank.'
          next
        end

        Session.new(question).run
        return
      end
    end
  end
end
