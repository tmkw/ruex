# frozen_string_literal: true

require "ruex"
require "ruex/version"

module Ruex
  class CLI
    include Ruex

    HELP = <<~TEXT
      Render ruex expressions as HTML.

      Usage:
        echo 'p "hello"' | ruex
        ruex -e 'p "hello"'
        ruex -f template.ruex

      Options:
        -e, --expr EXPR       Evaluate EXPR instead of reading from stdin
        -f, --file FILE       Read Ruex DSL from FILE
        -v, --version         Show Ruex version
        -h, --help            Show this help message
    TEXT

    def run(argv)
      expr = nil
      file = nil

      args = argv.dup

      until args.empty?
        opt = args.shift

        case opt
        when "-h", "--help"
          puts HELP
          return

        when "-v", "--version"
          puts Ruex::VERSION
          return

        when "-e", "--expr"
          expr = args.shift

        when "-f", "--file"
          file = args.shift

        else
          warn "Unknown option: #{opt}"
          puts HELP
          return
        end
      end

      input =
        if expr
          expr
        elsif file
          File.read(file)
        else
          $stdin.read
        end

      input = input.to_s.strip
      return if input.empty?

      puts render(input)
    end
  end
end

