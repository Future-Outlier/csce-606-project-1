# Defines how the tarot app reads and responds to terminal commands.
module TarotCLI
  class CLI
    USAGE = <<~TEXT.freeze
      Usage: tarot [command]

      Commands:
        help, -h, --help  Show this help
        exit, quit         Exit tarot-cli
    TEXT

    # Allows the CLI to use the real terminal or another input and output source.
    def initialize(input: $stdin, output: $stdout)
      @input = input
      @output = output
    end

    # Runs one command or keeps reading commands until the interactive session ends.
    def run(arguments = [])
      unless arguments.empty?
        result = execute(arguments.join(" "))
        return result == :unknown ? 1 : 0
      end

      output.puts "Welcome to tarot-cli."
      output.puts "Type 'help' to see available commands."

      while (line = input.gets)
        break if execute(line) == :exit
      end

      0
    end

    private

    attr_reader :input, :output

    # Converts one line of input into help, exit, or an error response.
    def execute(line)
      command = line.strip

      case command
      when ""
        nil
      when "help", "-h", "--help"
        output.puts USAGE
      when "exit", "quit"
        :exit
      else
        output.puts "Unknown command: #{command}"
        output.puts "Type 'help' to see available commands."
        :unknown
      end
    end
  end
end
