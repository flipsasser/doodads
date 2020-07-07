# frozen_string_literal: true

module Doodads
  module Errors
    class ComponentRequiredError < StandardError
      def initialize(method, *args)
        args = args.map(&:inspect).join(", ")
        message = "You cannot call `#{method}` outside of a component definition block."
        details = "Try calling it inside a component, e.g. `component(:button) { #{method}(#{args}) }`"
        super "#{message}\n\n#{details}"
      end
    end
  end
end
