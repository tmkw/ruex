require 'ruex'

module Ruex
  class CLI
    include Ruex

    def run(expr: nil, file: nil, ctx: {})
      input = if expr
                expr
              elsif file
                File.read(file)
              else
                $stdin.read
              end

      input = input.to_s.strip
      return if input.empty?

      puts render(input, ctx: ctx)
    end
  end
end

