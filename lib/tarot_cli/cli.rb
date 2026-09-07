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

    def initialize(input: $stdin, output: $stdout)
      @input = input
      @output = output
    end

    def run(arguments = [])
      unless arguments.empty?
        result = execute(arguments.join(' '))
        return result == :unknown ? 1 : 0
      end

      output.puts <<~TEXT
        Welcome to tarot-cli.
        Type \'help\' to see available commands.

      TEXT

      while (line = input.gets)
        break if execute(line) == :exit
      end

      0
    end

    private

    attr_reader :input, :output

    def execute(line)
      command = line.strip

      case command
      when ''
        nil
      when 'help', '-h', '--help'
        output.puts USAGE
      when 'new'
        output.puts 'Enter your intention or question for this session: '
        question = gets.chomp
        session = Session.new(question)
        session.run
      when 'review'
        output.puts 'not yet implemented'
      when 'load'
        output.puts 'not yet implemented'
      when 'reset'
        output.puts 'No session initiated. Nothing to reset.'
        :exit
      when 'exit', 'quit'
        :exit
      else
        output.puts "Unknown command: #{command}"
        output.puts "Type 'help' to see available commands."
        :unknown
      end
    end
  end
end
