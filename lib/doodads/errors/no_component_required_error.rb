# frozen_string_literal: true

module Doodads
  module Errors
    class NoComponentRequiredError < StandardError
      def initialize(method, *args)
        args = args.map(&:inspect).join(", ")
        message = "You cannot call `#{method}` inside of a component definition block."
        details = "Try calling it at the root level, e.g. `#{method}(#{args}); component(:button)`"
        super "#{message}\n\n#{details}"
      end
    end
  end
end
