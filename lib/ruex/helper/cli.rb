module Ruex
  module Helper
    module CLI
      require "json"
      require "yaml"

      def load_help
        help_path = File.expand_path("../../../doc/help", __dir__)
        File.read(help_path)
      end

      # Convert "foo/bar_baz" → "Foo::BarBaz"
      def path_to_module_name(lib)
        lib
          .sub(/\.rb$/, "")
          .split("/")
          .map { |seg| seg.split("_").map(&:capitalize).join }
          .join("::")
      end

      class ContextFile
        def self.read(path_or_io)
          data = if path_or_io.is_a?(StringIO)
                   stringio_contents(path_or_io)
                 else
                   context_file_contents(path_or_io)
                 end
          deep_symbolize(data)
        end

        def self.deep_symbolize(obj)
          case obj
          when Hash
            obj.each_with_object({}) do |(k, v), h|
              h[k.to_sym] = deep_symbolize(v)
            end
          when Array
            obj.map { |v| deep_symbolize(v) }
          else
            obj
          end
        end

        def self.stringio_contents(sio)
          data = Psych.safe_load(sio.read, permitted_classes: [Symbol], aliases: false)
          raise ArgumentError, "-b expects a Hash literal" unless data.is_a?(Hash)
          data
        rescue Psych::DisallowedClass
          raise ArgumentError, "-b expects a Hash literal"
        rescue Psych::SyntaxError
          raise ArgumentError, "Invalid -b hash"
        end

        def self.context_file_contents(path)
          contents = File.read(path)
          data =
            case File.extname(path)
            when ".yml", ".yaml"
              Psych.safe_load(contents, permitted_classes: [Symbol], aliases: false)
            when ".json"
              JSON.parse(contents)
            else
              raise ArgumentError, "Unknown context file format: #{path}"
            end

          raise ArgumentError, "Context file must contain a top-level Hash/Map object" unless data.is_a?(Hash)

          data
        rescue Psych::DisallowedClass
          raise ArgumentError, "disallowed class"
        end
      end
    end
  end
end

