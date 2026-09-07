module TarotCLI
  class CLI
    USAGE = <<~TEXT.freeze
      Usage: tarot [command]

      Commands:
        help, -h, --help  Show this help
        exit, quit         Exit tarot-cli
    TEXT

    # Supports both shell-friendly one-shot commands and a persistent interactive session.
    def run(arguments = [])
      unless arguments.empty?
        result = execute(arguments.join(" "))
        return result == :unknown ? 1 : 0
      end

      puts "Welcome to tarot-cli."
      puts "Type 'help' to see available commands."

      while (line = gets)
        break if execute(line) == :exit
      end

      0
    end

    private

    # Returns command outcomes so run can choose the correct exit status.
    def execute(line)
      command = line.strip

      case command
      when ""
        nil
      when "help", "-h", "--help"
        puts USAGE
      when "exit", "quit"
        :exit
      else
        puts "Unknown command: #{command}"
        puts "Type 'help' to see available commands."
        :unknown
      end
    end
  end
end
