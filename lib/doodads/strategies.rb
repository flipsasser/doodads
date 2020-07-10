# frozen_string_literal: true

require "doodads/strategies/base"

module Doodads
  module Strategies
    autoload(:MaintainableCSS, "doodads/strategies/maintainable_css")

    class << self
      def all
        @all ||= {}.with_indifferent_access
      end

      def get(name)
        class_name = class_name_for_strategy(name)
        strategy = all[name]
        strategy ||= "#{self.name}::#{class_name}".safe_constantize
        raise Doodads::Errors::StrategyMissingError.new(name, class_name) if strategy.blank?
        strategy.new
      end

      def register(name, strategy)
        all[name] = strategy
      end

      private

      def class_name_for_strategy(name)
        name.to_s.split("_").map(&:upcase_first).join.gsub("Css", "CSS")
      end
    end
  end
end
