module Doodads
  module CSSStrategies
    autoload(:MaintainableCSS, "doodads/css_strategies/maintainable_css")

    def self.get(name)
      const_get(class_name_for_strategy(name)).new
    rescue NameError
      raise StrategyMissingError.new(name)
    end

    def self.class_name_for_strategy(name)
      name.to_s.split("_").map(&:upcase_first).join.gsub("Css", "CSS")
    end

    class StrategyMissingError < StandardError
      def initialize(name)
        module_names = self.class.to_s.split("::")
        module_names.pop
        super "Could not find a CSS strategy named #{name.inspect} (expected to find #{module_names.join("::")}::#{Doodads::CSSStrategies.class_name_for_strategy(name)})"
      end
    end
  end
end
