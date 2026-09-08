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
      execute_command(command) unless command.empty?
    end

    def execute_command(command)
      case command
      when 'help', '-h', '--help' then puts USAGE
      when 'new' then start_session
      when 'review', 'load' then puts 'not yet implemented'
      when 'reset' then reset_without_session
      when 'exit', 'quit' then :exit
      else
        unknown_command(command)
      end
    end

    def start_session
      puts 'Enter your intention or question for this session: '
      Session.new(gets.chomp).run
    end

    def reset_without_session
      puts 'No session initiated. Nothing to reset.'
      :exit
    end

    def unknown_command(command)
      puts "Unknown command: #{command}"
      puts "Type 'help' to see available commands."
      :unknown
    end
  end
end
