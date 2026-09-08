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
        puts 'Enter your intention or question for this session: '
        question = gets.chomp
        session = Session.new(question)
        session.run
      when 'review'
        puts 'not yet implemented'
      when 'load'
        puts 'not yet implemented'
      when 'reset'
        puts 'No session initiated. Nothing to reset.'
        :exit
      when 'exit', 'quit'
        :exit
      else
        puts "Unknown command: #{command}"
        puts "Type 'help' to see available commands."
        :unknown
      end
    end
  end
end
