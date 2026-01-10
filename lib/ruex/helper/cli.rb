module Ruex
  module Helper
    module CLI
      require "json"
      require "yaml"

      # Convert "foo/bar_baz" → "Foo::BarBaz"
      def path_to_module_name(lib)
        lib
          .sub(/\.rb$/, "")
          .split("/")
          .map { |seg| seg.split("_").map(&:capitalize).join }
          .join("::")
      end

      # Load YAML/JSON context file
      def load_context_file(path)
        data =
          case File.extname(path)
          when ".yml", ".yaml"
            YAML.load_file(path)
          when ".json"
            JSON.parse(File.read(path))
          else
            raise ArgumentError, "Unknown context file format: #{path}"
          end

        unless data.is_a?(Hash)
          raise ArgumentError, "Context file must contain a top-level Hash/Mapo bject"
        end

        # symbolize keys
        data.transform_keys(&:to_sym)
      end

      def load_help
        help_path = File.expand_path("../../../doc/help", __dir__)
        File.read(help_path)
      end
    end
  end
end

