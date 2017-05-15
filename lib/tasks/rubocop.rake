# frozen_string_literal: true

desc 'run rubocop'
task(:rubocop) do
  require 'rubocop'
  cli = RuboCop::CLI.new
  cli.run
end

task default: %i[rubocop test]
