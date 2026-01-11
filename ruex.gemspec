require_relative 'lib/ruex/version.rb'

Gem::Specification.new do |s|
  s.name        = "ruex"
  s.version     = Ruex::VERSION
  s.summary     = "Static HTML generation with plain Ruby expressions"
  s.description = "A library and CLI tool that generates HTML using plain Ruby expressions.
It is intended for static site or page generation, and is not suitable as a dynamic web page renderer."
  s.authors     = ["Takanobu Maekawa"]
  s.files       = Dir['lib/**/*.rb', 'VERSION']
  s.files       = Dir[ "lib/**/*", "README.md", "LICENSE", "VERSION", "doc/help" ]
  s.homepage    = "https://github.com/tmkw/ruex"
  s.license     = 'BSD-2-Clause'
  s.required_ruby_version = '>= 4.0.0'
  s.metadata = {
    "homepage_uri" => "https://github.com/tmkw/ruex",
    "source_code_uri" => "https://github.com/tmkw/ruex"
  }
  s.bindir = 'bin'
  s.executables = Dir["bin/*"].map { |f| File.basename(f) }
end

