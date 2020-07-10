# frozen_string_literal: true

module Doodads
  module Errors
    class StrategyMissingError < StandardError
      def initialize(name, class_name)
        message = "Could not find a CSS strategy named :#{name}"
        details = "Expected to find either a manually registered strategy (e.g. `Doodads::Strategies.register(:bootstrap, MyBootstrapStrategy)`) or an existing class (`Doodads::Strategies::#{class_name}`)"
        super "#{message}\n\n#{details}"
      end
    end
  end
end
