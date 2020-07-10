# frozen_string_literal: true

require "doodads/flags"

module Doodads
  module Errors
    class FlagSetMissing < StandardError
      def initialize(name)
        message = "Flag set :#{name} could not be found."
        flags = Doodads::Flags.keys.map { |flag| ":#{flag}" }.to_sentence
        details = " Available flags are: #{flags}"
        super "#{message} #{details}"
      end
    end
  end
end
