# frozen_string_literal: true

require "rake"

desc "Run all tests"
task :test do
  ruby "-Ilib -e 'Dir[\"test/test_*.rb\"].each { |f| require_relative f }'"
end
