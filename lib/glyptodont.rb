# frozen_string_literal: true

require_relative "glyptodont/checkers/age"
require_relative "glyptodont/checkers/counter"
require_relative "glyptodont/configuration"
require_relative "glyptodont/formatting"
require_relative "glyptodont/options"
require_relative "glyptodont/todo_researcher"

require "forwardable"

# This is where the magic happens
module Glyptodont
  class << self
    def check
      @options = Options.new
      @configuration = Configuration.new(directory)

      todos = TodoResearcher.new(directory, ignore).research

      checks = [
        Checkers::Counter.new(todos: todos, threshold: threshold),
        Checkers::Age.new(todos: todos, threshold: max_age_in_days)
      ].freeze

      checks.each { |check| puts check.check }

      checks.all?(&:passed?)
    end

    attr_reader :configuration, :options

    extend Forwardable

    def_delegator :@configuration, :ignore
    def_delegators :@options, :directory, :threshold, :max_age_in_days
  end
end
